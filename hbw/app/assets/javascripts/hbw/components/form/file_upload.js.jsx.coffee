modulejs.define 'HBWFormFileUpload',
  ['React', 'jQuery', 'HBWDeleteIfMixin', 'HBWCallbacksMixin'],
  (React, jQuery, DeleteIfMixin, CallbacksMixin) ->
    React.createClass
      mixins: [DeleteIfMixin, CallbacksMixin]

      getInitialState: ->
        {valid: true, files: [], filesCount: 0}

      render: ->
        opts = {
          name: @props.params.name
          onChange: @onChange
        }

        incomingFiles = []
        incomingCount = 0

        if (@props.value)
          incomingFiles = JSON.parse(@props.value).files
          incomingCount = incomingFiles.length

        hiddenValue = JSON.stringify({files: @state.files.concat(incomingFiles)})

        cssClass = @props.params.css_class
        cssClass += ' hidden' if this.hidden

        label = @props.params.label
        labelForCount = @props.params.label_for_count
        labelCss = @props.params.label_css

        `<div className={cssClass}>
          <span className={labelCss}>{label}</span>
          {this.countLabel(incomingCount, labelForCount)}
          <div className="form-group">
            <input {...opts} type="file" multiple></input>
            <input name={this.props.params.name} value={hiddenValue} type="hidden"/>
          </div>
        </div>`

      onChange: (event) ->
        @trigger('hbw:file-upload-started')
        $el = event.target
        files = Array.from($el.files)

        @setState(files: [], filesCount: files.length)

        for file in files
          @readFiles(file.name, file)

      addValue: (name, res) ->
        files = @state.files
        files.push({name: name, content: window.btoa(res)})

        @setState(files: files, filesCount: @state.filesCount - 1)

        if (@state.filesCount == 0)
          @trigger('hbw:file-upload-finished')

      countLabel: (incomingCount, labelForCount) ->
        if incomingCount > 0
          `<span><br/>{labelForCount}: {incomingCount}</span>`

      readFiles: (name, file) ->
        fileReader = new FileReader()
        fileReader.onloadend = () =>
          @addValue(name, fileReader.result)
        fileReader.readAsBinaryString(file)
