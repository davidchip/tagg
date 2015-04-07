"""Command line interface for Firecracker
"""

crackName = process.argv.slice(2)
template = """
Firecracker.register_group('#{crackName}', {

    template: \"\"\"

    \"\"\"

    style: \"\"\"

    \"\"\"

})
"""

fs = require('fs')
fs.writeFile("./src/cracks/" + crackName + ".coffee", template, (err) ->
    if err 
        return console.log(err)

    console.log("The file was saved!")
) 

