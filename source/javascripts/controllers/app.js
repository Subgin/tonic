export default class AppCtrl {
  constructor() {
    self.currentFilters = {}

    const defaultOrder =
      window.config.sorting && window.config.sorting.default_order ||
      'name asc'

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

  filterBy(type, attribute = '_global_', options = {}) {
    addClass('article', 'hidden')

    const el = currentElement()
    const currentValue = el.value
    attribute = el.name || attribute

    self.currentFilters[attribute] = { type, attribute, currentValue, options }

    if (type == 'tags') {
      removeClass('.tag', 'active')
      addClass(el, 'active')
    }

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
    let itemValue = item[filter.attribute]

    switch(filter.type) {
      case 'global_text':
        const values = Object.values(item).filter(isString)

        if (values.join(' ').match(new RegExp(filter.currentValue, 'i')))
          return true

        break;
      case 'text':
        if (itemValue.match(new RegExp(filter.currentValue, 'i')))
          return true

        break;
      case 'select':
      case 'radio_buttons':
        if (filter.currentValue == 'All' || filter.currentValue == itemValue)
          return true

        break;
      case 'numeric_range':
        itemValue = item[filter.attribute.replace(/_min$|_max$/, '')]
        const currentValue = parseInt(filter.currentValue)

        if (filter.options['range'] == 'min' && itemValue >= currentValue)
          return true

        if (filter.options['range'] == 'max' && itemValue <= currentValue)
          return true

        break;
      case 'tags':
        if (itemValue && itemValue.includes(filter.options['tag']))
          return true

        break;
      case 'boolean':
        if (filter.currentValue == 'true' && itemValue)
          return true

        if (filter.currentValue == 'false' && !itemValue)
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
