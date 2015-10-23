## this should combine with helix-base

tag.define('tag-root', {
    extends: ''

    mapNameToPath: (tagName) =>
        return ("/" + tagName.replace(/\-/g, "/"))

    mapNameToParent: (tagName) =>
        tagParts = tagName.split('-')
        
        lastPart = tagParts.pop()
        if lastPart isnt "root"
            tagParts.push("root")
        
        return tagParts
})
