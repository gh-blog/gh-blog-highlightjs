through2 = require 'through2'
{ highlight, highlightAuto } = require 'highlight.js'
File = require 'vinyl'
fs = require 'fs'

module.exports = (options = { theme: 'github' }) ->
    { theme } = options
    
    themeFile = new File {
        path: "styles/#{theme}.css"
    }

    themeFile.contents = fs.readFileSync "#{__dirname}/node_modules/\
    highlight.js/styles/#{theme}.css"

    processFile = (file, enc, done) ->
        if file.isPost
            { $ } = file
            $('pre code').each (i, block) ->
                $block = $(block)
                lang = $block.attr('class').match(/lang-(\S*)/i)?[1]
                code = $block.text()
                if lang
                    code = highlight(lang, code, yes).value
                else
                    code = highlightAuto(code, yes).value
                $block.html code

            file.contents = new Buffer $.html()
            file.styles.push themeFile.path

        done null, file

    through2.obj processFile, (done) ->
        @push themeFile
        done()