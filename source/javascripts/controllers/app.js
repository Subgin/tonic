const DEFAULT_ORDER = 'name asc'

export default class AppCtrl {
  constructor() {
    self.currentFilters = {}

    const defaultOrder =
      window.config.sorting && window.config.sorting.default_order ||
      DEFAULT_ORDER

    this.sortBy(defaultOrder, false)
  }

  toggleSidebar() {
    toggleClass('#sidebar', 'hidden')
    toggleClass('#open', 'hidden')
    toggleClass('#close', 'hidden')
  }

  toggleSorting() {
    toggleClass('.sorting-options', 'hidden')
  }

  filterBy(type) {
    const el = currentElement()
    self.currentFilters[el.name] = {
      element: el,
      type: type
    }

    addClass('article', 'hidden')
    if (type == 'tags') toggleClass(el, 'active')

    window.collection.forEach(item => {
      let show = true

      Object.values(self.currentFilters).forEach((filter) => {
        show = show && applyFilter(item, filter)
        if (!show) return
      })

      if (show) showItem(item)
    })

    insertHTML('#counter', findAll('article:not(.hidden)').length)
  }

  applyFilter(item, filter) {
    const el = filter.element
    const attribute = el.name
    let filterValue = el.value
    let itemValue = item[attribute]

    switch(filter.type) {
      case 'global_text':
        const values = Object.values(item).filter(isString)

        if (values.join(' ').match(new RegExp(filterValue, 'i')))
          return true

        break;
      case 'text':
        if (itemValue.match(new RegExp(filterValue, 'i')))
          return true

        break;
      case 'select':
      case 'radio_buttons':
        if (filterValue == 'All' || filterValue == itemValue)
          return true

        break;
      case 'numeric_range':
        itemValue = item[attribute.replace(/_min$|_max$/, '')]
        filterValue = parseInt(filterValue) || 0

        if (attribute.match(/_min$/) && itemValue >= filterValue)
          return true

        if (attribute.match(/_max$/) && itemValue <= filterValue)
          return true

        break;
      case 'date_range':
        itemValue = Date.parse(item[attribute.replace(/_min$|_max$/, '')])
        const filterDate = Date.parse(filterValue)

        if (attribute.match(/_min$/) && itemValue >= filterDate)
          return true

        if (attribute.match(/_max$/) && itemValue <= filterDate)
          return true

        break;
      case 'tags':
        let activeTags = Array.from(findAll('.tag.active')).map(tag => tag.value)

        if (itemValue && activeTags.every(tag => itemValue.includes(tag)))
          return true

        break;
      case 'boolean':
        if (filterValue == 'true' && itemValue)
          return true

        if (filterValue == 'false' && !itemValue)
          return true

        break;
      default:
        return false
    }
  }

  sortBy(sorting, toggleSorting = true) {
    const [attribute, direction] = sorting.split(' ')
    const itemsContainer = find('.items-container')
    const items = []

    findAll('article:not(.hidden)').forEach(itemDom => {
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
      itemsContainer.appendChild(find(`#${item.dom_id}`))
    })

    removeClass('.sorting-options a', 'active')
    findAll('.sorting-options a').forEach(option => {
      if (option.innerText.toLowerCase() == sorting)
        addClass(option, 'active')
    })

    if (toggleSorting) this.toggleSorting()
  }

  showItem(item) {
    removeClass(`#${item.dom_id}`, 'hidden')
  }

  isString(string) {
    if (typeof string === 'string' || string instanceof String)
      return true
  }
}
