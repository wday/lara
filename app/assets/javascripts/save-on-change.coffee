
class SaveOnChange
  changeInterval: 200  # Fire change and blur events almost instantly.
  keyUpinterval:  2000 # Fire keyup events with a larger delay
  constructor: (@$form, @page) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()

  setupEvents: ->

    @$form.find('input,textarea,select').on 'change blur', (e) =>
      @schedule(@changeInterval)
    @$form.find('input,textarea').on 'keyup',  (e) =>
      @schedule(@keyUpinterval)

  saveElement:(async = true) ->
    data = @$form.serialize()
    @page.saving()
    $.ajax({
      type: "POST",
      async: async,
      url: @$form.attr( 'action' ),
      data: @$form.serialize(),
      success: (response) =>
        @previous_value = data
        @page.saved(@)
        @dirty = false
      error: (jqxhr, status, error) =>
        @page.failed(@)
    })

  saveNow: ->
    @unschedule()
    @saveElement(false)

  # remove events scheduled for elem
  unschedule: () ->
    clearTimeout(@scheduled_job) if @scheduled_job
    @scheduled_job = null

  schedule:  (interval) ->
    @unschedule() # remove any existing events
    dirty = (@previous_value != @$form.serialize())
    if dirty
      @page.mark_dirty(this)
      action = () =>
        @saveElement()
      @scheduled_job = setTimeout(action, interval)


class SaveOnChangePage
  constructor: () ->
    @save_indicator = SaveIndicator.instance()
    @intercept_navigation()
    @forms = []
    if $('.live_submit').length
      $('.live_submit').each (i,e) =>
        @forms.push(new SaveOnChange($(e),@))
    @dirty_forms = {}

  intercept_navigation: ->
    $("a").not('.colorbox').not('[target]').on 'click', (e) =>
      @stored_location = e.currentTarget.href
      @force_save_dirty()
      e.preventDefault()

  saving: (form) ->
    @save_indicator.showSaving()

  saved: (form) ->
    @save_indicator.showSaved()
    @mark_clean(form)

  failed: (form) ->
    @save_indicator.showSaveFailed()

  mark_dirty: (form) ->
    @dirty_forms[form] = form;

  navigate_away: ->
    if @stored_location
      window.location = @stored_location

  mark_clean: (form) ->
    delete @dirty_forms[form]

  force_save_dirty: ->
    for item, value of @dirty_forms
      value.saveNow()
    waiting_on = IFrameSaver.instances.length
    found      = 0
    if waiting_on > 0
      for count, saver of IFrameSaver.instances
        saver.save =>
          found = found + 1
          if (found + 1 ) >= waiting_on
            @navigate_away()
    else
      @navigate_away()


$(document).ready ->
  window.SaveOnChangePage = SaveOnChangePage
  window.SaveOnChange     = SaveOnChange
  new SaveOnChangePage()
