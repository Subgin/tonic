export default class AppCtrl {
  constructor() {
    self.filteredCollection = []
  }

  toggleSidebar() {
    toggleClass("#sidebar", "hidden")
    toggleClass("#open", "hidden")
    toggleClass("#close", "hidden")
  }

  filterBy(type, attribute = null, options = {}) {
    addClass('.card', 'hidden')

    const el = currentElement()
    const currentValue = el.value

    const currentCollection = !self.filteredCollection.length ? window.collection : self.filteredCollection
    self.filteredCollection = []

    currentCollection.forEach((item) => {
      const itemVal = item[attribute]

      switch(type) {
        case 'global_text':
          const attrs = Object.values(item).filter(isString)

          if (attrs.join(" ").match(currentValue))
            showItem(item)

          break;
        case 'text':
          if (currentValue.match(itemVal))
            showItem(item)

          break;
        case 'select':
          if (currentValue == itemVal)
            showItem(item)

          break;
        case 'numeric_range':
          if (options['range'] == 'min' && itemVal > currentValue)
            showItem(item)

          if (options['range'] == 'max' && itemVal < currentValue)
            showItem(item)

          break;
        case 'tags':
          if (itemVal && itemVal.includes(options['tag']))
            showItem(item)

          break;
        case 'boolean':
          if (currentValue == 'true' && itemVal)
            showItem(item)

          if (currentValue == 'false' && !itemVal)
            showItem(item)

          break;
      }
    })
  }

  showItem(item) {
    self.filteredCollection.push(item)
    removeClass(`#${item.dom_id}`, 'hidden')
  }

  isString(string) {
    if (typeof string === 'string' || string instanceof String)
      return true
  }
}
