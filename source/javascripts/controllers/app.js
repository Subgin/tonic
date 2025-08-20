import { contains, stripTags, deepValues, sortArray } from '../utils'

export default class AppCtrl {
  constructor() {
    self.currentFilters = {}

    // Initialize dropdown management
    this.initializeDropdownManagement()

    // Initialize dynamic header height positioning
    this.updateHeaderHeightPositioning()
    on(window, 'resize', () => { this.updateHeaderHeightPositioning() })

    setTimeout(() => {
      // Apply filtering by params
      this.defaultFilters()

      // Apply default sorting
      const defaultOrder = getParam('sorting') || window.config.sorting.default_order
      this.sortBy(defaultOrder, false)
    })
  }

  initializeDropdownManagement() {
    // Close dropdowns when clicking outside
    document.addEventListener('click', (event) => {
      // Don't close if clicking on a dropdown button or inside a dropdown
      if (event.target.closest('button[onclick*="toggle"]') || event.target.closest('.dropdown')) {
        return
      }
      
      // Close all dropdowns
      this.closeAllDropdowns()
    })
  }

  closeAllDropdowns() {
    // Close all dropdown menus
    addClass('#sorting-options', 'hidden')
    addClass('#sharing-options', 'hidden')
    addClass('#mobile-menu-dropdown', 'hidden')
    
    // Reset mobile menu icon
    removeClass('#mobile-menu-icon', 'hidden')
    addClass('#mobile-close-icon', 'hidden')
  }

  toggleDropdown(dropdownId, iconId = null, closeIconId = null) {
    const isHidden = hasClass(dropdownId, 'hidden')
    
    // Close all dropdowns first
    this.closeAllDropdowns()
    
    // If the dropdown was hidden, show it
    if (isHidden) {
      removeClass(dropdownId, 'hidden')
      
      // Toggle icons if provided
      if (iconId && closeIconId) {
        addClass(iconId, 'hidden')
        removeClass(closeIconId, 'hidden')
      }
    }
  }

  updateHeaderHeightPositioning() {
    // Get the actual header height
    const headerHeight = find('#header').offsetHeight
    
    // Update sidebar positioning
    style('#sidebar', `top: ${headerHeight}px; height: calc(100vh - ${headerHeight}px)`)
    
    // Update main content positioning
    style('#main-content', `margin-top: ${headerHeight}px`)
  }

  toggleSidebar() {
    toggleClass('#sidebar', 'hidden')
    toggleClass('#sidebar-overlay', 'hidden')
    
    // Toggle between menu and close icons
    toggleClass('#menu-icon', 'hidden')
    toggleClass('#close-icon', 'hidden')
  }

  toggleSorting() {
    this.toggleDropdown('#sorting-options')
  }

  toggleSharing() {
    const isHidden = hasClass('#sharing-options', 'hidden')
    this.toggleDropdown('#sharing-options')

    // Prepare data-* attributes for share & copy actions only when opening
    if (isHidden) {
      attr('#share_url', 'value', currentUrl())
      findAll('#sharing-buttons a').forEach(el => {
        data(el, { title: find('title').innerText, url: currentUrl() })
      })
    }
  }

  toggleMobileMenu() {
    this.toggleDropdown('#mobile-menu-dropdown', '#mobile-menu-icon', '#mobile-close-icon')
  }

  defaultFilters() {
    Object.entries(getParam()).forEach(([key, value]) => {
      if (!value || key == 'sorting') return

      const el = find(`#${key}`) || find(`#${key}_${value}`)

      switch(el?.type) {
        case 'number':
        case 'text':
          el.value = value
          el.dispatchEvent(new KeyboardEvent('keyup'))

          break;
        case 'date':
        case 'select-one':
          el.value = value
          el.dispatchEvent(new KeyboardEvent('change'))

          break;
        case 'radio':
          el.click()

          break;
        case 'submit':
          value.split(',').forEach(tag => {
            find(`#tags_${tag}`).click()
          })

          break;
      }
    })
  }

  filterBy(type) {
    const el = currentElement()
    self.currentFilters[el.name] = {
      element: el,
      type: type
    }

    // Show loading indicator
    showLoading()

    // Start fade-out animation for all items
    findAll('article').forEach(article => {
      removeClass(article, 'filtering-in')
      addClass(article, 'filtering-out')
    })

    // Hide sharing menu
    addClass('#sharing-options', 'hidden')

    // Display reset link
    removeClass('#reset', 'hidden')

    // Update URL parameters
    setParam(el.name, el.value)

    // Specific handling for tags
    if (type == 'tags') {
      toggleClass(el, 'active')
      setParam(el.name, activeTags())
    }

    // Process filtering after fade-out animation
    setTimeout(() => {
      // Hide all items and reset their animation states
      findAll('article').forEach(article => {
        addClass(article, 'hidden')
        removeClass(article, 'filtering-out')
        removeClass(article, 'filtering-in')
      })

      window.collection.forEach(item => {
        let show = true

        Object.values(self.currentFilters).forEach((filter) => {
          show = show && applyFilter(item, filter)
          if (!show) return
        })

        if (show) showItem(item)
      })

      // Update counter with visible items
      insertHTML('#counter', activeItems().length)

      // Hide loading indicator
      hideLoading()
    }, 300) // Match the CSS transition duration
  }

  applyFilter(item, filter) {
    const el = filter.element
    const attribute = el.name
    let filterValue = el.value
    let itemValue = item[attribute]

    switch(filter.type) {
      case 'global_text':
        const itemContent = deepValues(item)

        if (contains(stripTags(itemContent), filterValue))
          return true

        break;
      case 'text':
        if (itemValue instanceof Object)
          itemValue = deepValues(itemValue)

        if (contains(itemValue, filterValue))
          return true

        break;
      case 'select':
      case 'radio_buttons':
        if (filterValue == 'All' || filterValue == itemValue)
          return true

        break;
      case 'numeric_range':
        itemValue = item[attribute.replace(/_min$|_max$/, '')]
        filterValue = parseFloat(filterValue) || 0

        if (contains(attribute, '_min$') && itemValue >= filterValue)
          return true

        if (contains(attribute, '_max$') && itemValue <= filterValue)
          return true

        break;
      case 'date_range':
        itemValue = Date.parse(item[attribute.replace(/_min$|_max$/, '')])
        filterValue = Date.parse(filterValue)

        if (contains(attribute, '_min$') && itemValue >= filterValue)
          return true

        if (contains(attribute, '_max$') && itemValue <= filterValue)
          return true

        break;
      case 'tags':
        if (itemValue && activeTags().every(tag => itemValue.includes(tag)))
          return true

        break;
      case 'boolean':
        if (filterValue == 'All')
          return true

        if (filterValue == 'true' && itemValue)
          return true

        if (filterValue == 'false' && !itemValue)
          return true

        break;
      default:
        return false
    }
  }

  sortBy(sorting, interactive = true) {
    if (interactive) showLoading()

    const [attribute, direction] = sorting.split(' ')
    const container = find('#collection-container')
    const items = []

    this.activeItems().forEach(itemDom => {
      let item = window.collection.find(item => item.dom_id == itemDom.id)
      items.push(item)
    })

    sortArray(items, attribute, direction).forEach(item => {
      container.appendChild(find(`#${item.dom_id}`))
    })

    // Highlight current sorting
    findAll('#sorting-options a').forEach(link => {
      const isActive = data(link, 'sortBy') == sorting
      toggleClass(link, 'active', isActive)
    })

    if (interactive) {
      setParam('sorting', sorting)
      toggleSorting()
      setTimeout(() => { hideLoading() }, 300)
    }
  }

  showItem(item) {
    const element = find(`#${item.dom_id}`)
    removeClass(element, 'hidden')
    removeClass(element, 'filtering-out')
    addClass(element, 'filtering-in')
  }

  hideItem(item) {
    const element = find(`#${item.dom_id}`)
    addClass(element, 'filtering-out')
    // Wait for fade-out animation to complete before hiding
    setTimeout(() => {
      addClass(element, 'hidden')
      removeClass(element, 'filtering-out')
      removeClass(element, 'filtering-in')
    }, 300)
  }

  showLoading() {
    removeClass('#loading-container', 'hidden')
  }

  hideLoading() {
    addClass('#loading-container', 'hidden')
  }

  activeTags() {
    return Array.from(findAll('.tag.active')).map(tag => tag.value)
  }

  activeItems() {
    return findAll('article:not(.hidden)')
  }

  copyToClipboard(target) {
    find(target).select()
    document.execCommand('copy')
  }
}
