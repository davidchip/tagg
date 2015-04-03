""" 
"""


Firecracker.register_group('code-snippet', {

    create: () ->
        escaped_html = document.createTextNode(@innerHTML)
        code_el = $('<code>').addClass('code').html(escaped_html)
        
        $(code_el).insertAfter(@)

})