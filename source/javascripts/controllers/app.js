export default class AppCtrl {
  constructor() {
    self.currentFilters = {}

    // Open Sidebar by default on bigger screens
    if (window.innerWidth > 900) this.toggleSidebar()

    // Apply filtering by params
    setTimeout(() => {
      this.defaultFilters(getParam())
    })

    // Apply default sorting
    const defaultOrder = window.config.sorting.default_order
    this.sortBy(defaultOrder, false)
  }

  toggleSidebar() {
    toggleClass('#sidebar', 'hidden')
  }

  toggleSorting() {
    toggleClass('.sorting-options', 'hidden')
  }

  defaultFilters(params = {}) {
    Object.entries(params).forEach(([key, value]) => {
      if (!value) return

      let el = find(`#${key}`)
      if (!el) el = find(`#${key}_${value}`)

      switch(el.type) {
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

    addClass('article', 'hidden')
    if (type == 'tags') toggleClass(el, 'active')

    if (type == 'tags')
      setParam(el.name, activeTags().join(','))
    else
      setParam(el.name, el.value)

    window.collection.forEach(item => {
      let show = true

      Object.values(self.currentFilters).forEach((filter) => {
        show = show && applyFilter(item, filter)
        if (!show) return
      })

      if (show) showItem(item)
    })

    insertHTML('#counter', activeItems().length)
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
        const filterDate = Date.parse(filterValue)

        if (contains(attribute, '_min$') && itemValue >= filterDate)
          return true

        if (contains(attribute, '_max$') && itemValue <= filterDate)
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
    const [attribute, direction] = sorting.split(' ')
    const container = find('.collection-container')
    const items = []

    this.activeItems().forEach(itemDom => {
      let item = window.collection.find(item => item.dom_id == itemDom.id)
      items.push(item)
    })

    items.sort((a, b) => {
      if (direction == 'asc') {
        if (a[attribute] < b[attribute]) return -1
        if (a[attribute] > b[attribute]) return 1
        return 0
      } else {
        if (a[attribute] < b[attribute]) return 1
        if (a[attribute] > b[attribute]) return -1
        return 0
      }
    }).forEach(item => {
      container.appendChild(find(`#${item.dom_id}`))
    })

    removeClass('.sorting-options a', 'active')
    findAll('.sorting-options a').forEach(option => {
      if (option.innerText.toLowerCase() == sorting)
        addClass(option, 'active')
    })

    if (interactive) this.toggleSorting()
  }

  showItem(item) {
    removeClass(`#${item.dom_id}`, 'hidden')
  }

  activeTags() {
    return Array.from(findAll('.tag.active')).map(tag => tag.value)
  }

  activeItems() {
    return findAll('article:not(.hidden)')
  }

  contains(content, search) {
    const regexp = new RegExp(search, 'i')
    return regexp.test(content)
  }

  stripTags(string) {
    const parseHTML = new DOMParser().parseFromString(string, 'text/html')
    return parseHTML.body.textContent || ''
  }

  deepValues(obj, values = []) {
    Object.values(obj).forEach(val => {
      if (val instanceof Object)
        deepValues(val, values)
      else
        values.push(val)
    })

    return values.join(' ')
  }
}
