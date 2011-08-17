class Query
  modifier: "after"
  event: null
  prop: null
  
  constructor: (@query) ->
    query = @query.split(":")
    
    switch query.length
      when 3 then [@modifier, @event, @prop] = query
      when 2 then [@event, @prop] = query
      when 1 then [@event] = query


class Ed
  @before:
    change: (target, property, cb) -> target.__lookupSetter__(property).before.push(cb)
      
  @after:
    read: (target, property, cb) -> target.__lookupGetter__(property).after.push(cb)
    change: (target, property, cb) -> target.__lookupSetter__(property).after.push(cb)
  
  constructor: (@target) ->
    throw new Error("Cannot wrap constructors; use ed.ify instead") if @target.prototype?
  
  augment: (properties...) ->
    self = @
    for property in properties
      do (property) ->
        getter = self.target.__lookupGetter__(property)
        setter = self.target.__lookupSetter__(property)
        
        unless getter and getter.after
          if getter or setter
            baseGet = getter
            baseSet = setter
          else
            local = self.target[property]
            baseGet = -> local
            baseSet = (value) -> local = value
            
          getter = ->
            context = this
            event = 
              context: context
              property: property
              value: baseGet()
              change: (value) -> @value = value
            
            cb.call(context, event) for cb in getter.after
            
            event.value
            
          setter = (value) ->
            context = this
            event = 
              context: context
              property: property
              value: value
              oldValue: local
              change: (value) -> @value = value
              cancelled: false
              cancel: (cancelled) -> @cancelled = cancelled != false
              
            cb.call(context, event) for cb in setter.before when not event.cancelled
            
            unless event.cancelled
              baseSet(event.value)
              
              delete event.change
              delete event.cancelled
              delete event.cancel
              
              cb.call(context, event) for cb in setter.after
          
          getter.after = []
          setter.before = []
          setter.after = []
          
          self.target.__defineGetter__ property, getter
          self.target.__defineSetter__ property, setter
    @
  
  before: (query, cb) -> @on("before:#{query}", cb)
  on: (query, cb) ->
    
    query = new Query(query) unless query instanceof Query
    
    @augment query.prop
    
    throw new Error("Unsupported modifier: #{query.modifier}") unless Ed[query.modifier]
    throw new Error("Unsupported event/modifier: #{query.modifier}:#{query.event}") unless Ed[query.modifier][query.event]
    
    Ed[query.modifier][query.event](@target, query.prop, cb)

    @

ed = (object) ->
  new Ed(object)
  
ed.ify = (constructor) ->
  queue = []
  
  C = (args...) ->
    handle = ed(this)
    handle[e.method].apply(handle, e.arguments) for e in queue
    
    constructor.apply(this, args)
      
  C.prototype = constructor.prototype
  
  for method in ["on", "before"]
    do (method) ->
      C[method] = (args...) ->
        queue.push
          method: method
          arguments: args
        C
  
  C
  
module.exports = ed