""" 
"""


Firecracker.registerElement('code-snippet', {

    light: undefined

    create: () ->
        escaped_html = @innerHTML.replace(/[\u00A0-\u9999<>\&]/gim, (i) =>
            return '&#' + i.charCodeAt(0) + ';')
        
        code_html = @_format_into_code(escaped_html)

        theme = if @light then 'light-theme' else 'dark-theme'
        code_el = $('<code>').addClass(theme).html(code_html)

        $(code_el).insertAfter(@)

    _format_into_code: (raw_string, num_indents=12) ->
        formatted_string = ''

        ## remove global indentation
        newline_array = raw_string.split(/\r\n|\r|\n/g)
        indent = if newline_array.length > 0 then newline_array[1].match(/^\s{0,40}/)[0].length else 0

        for raw_line in newline_array
            ## remove the indent
            formatted_line = raw_line.slice(indent, raw_line.length)
            opening_carrot = formatted_line.indexOf('&#60;')
            closing_carrot = formatted_line.indexOf('&#62;')
            tagName_hyphen = formatted_line.indexOf('-')
            first_white_space_index = $.trim(formatted_line).indexOf(' ')

            if opening_carrot >= 0 and tagName_hyphen >= 0
                formatted_line = @_insert_string(formatted_line, "<b>", opening_carrot + 5)

                if first_white_space_index >=0
                    formatted_line = @_insert_string(formatted_line, "</b>", opening_carrot + first_white_space_index + "</b>".length - 1)
                else
                    formatted_line = @_insert_string(formatted_line, "</b>", closing_carrot + "</b>".length - 1)
                # formatted_line = @_insert_string(formatted_line, "</strong>", first_white_space)

            # alert tagName_hyphen
            # alert first_white_space

            # formatted_line.splice(1, 13)
            formatted_string += formatted_line + "\n"

        return formatted_string

    _insert_string: (base, insert, index) ->
        start = base.slice(0, index)
        end = base.slice(index, base.length)

        return start + insert + end
        # alert spaces_in + inserted_string.length
        # end_string = mid_string + base_string.slice(spaces_in + inserted_string.length,
                                                    # mid_string.length - 1)
        # console.log end_string




        # console.log start_string + inserted_string + end_string
        # end_string = 
        # return base_string.slice(0, spaces_in) + insert_string + base_string.(slice())

        # return (string_to_change.slice(0,idx) + s + string_to_change.slice(idx + Math.abs(rem)))


})