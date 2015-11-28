tag.trail_index = 0
tag.logs = {
    _all: {}
}


tag.assertEvent = (tagName, eventName, eventDetails) ->
    testingObj = {}
    testingObj[tagName] = {}
    testingObj[tagName][eventName] = eventDetails
    return tag.assert(testingObj)


tag.assert = (testingObj={}, delay=0) ->
    return new Promise ((testsFinished) =>
        timeout = new Promise ((timeoutCompleted) =>
            tag.loaded.then(() =>
                setTimeout (() =>
                    timeoutCompleted()
                ), delay
            )
        )

        timeout.then(() =>
            results = {
                passed: []
                failed: []
            }

            for tagName, tagCrumbs of testingObj
                if not tag.logs[tagName]?
                    results.failed.push("no crumbs dropped for #{tagName}")
                else
                    for crumbType, crumbTest of tagCrumbs
                        trailCrumb = tag.logs[tagName][crumbType]
                        if not trailCrumb?
                            results.failed.push("crumb of type #{crumbType} not dropped for #{tagName}")
                        else
                            if typeof crumbTest is "object"
                                for testKey, testValue of crumbTest
                                    crumbValue = trailCrumb[testKey]
                                    if crumbValue is testValue
                                        results.passed.push("crumb of type #{crumbType} for #{tagName} has detail #{testKey} equaling #{testValue}")
                                    else
                                        results.failed.push("crumb of type #{crumbType} for #{tagName} has a different value for #{testKey}. found as #{crumbValue} instead of #{testValue}")
                            else if typeof crumbTest is "function"
                                _crumbTest = crumbTest(trailCrumb)
                                if _crumbTest is true
                                    results.passed.push("crumb test function for #{crumbType} passed")
                                else
                                    results.failed.push("crumb test function for #{crumbType} failed")
                            else if typeof crumbTest is "number"
                                if trailCrumb["_length"] is crumbTest
                                    results.passed.push("crumb #{crumbType} found #{crumbTest} times")
                                else
                                    results.failed.push("crumb #{crumbType} found #{trailCrumb["_length"]} times, not #{crumbTest} times")

            if results.failed.length is 0
                console.log "passed test suite"
            else
                console.log "failed test suite"

            console.log results
            testsFinished(results)
        )
    )


tag.log = (tagName, type, msg, details={}) =>
    """Add event regarding a tagName the central log.
    """
    today = new Date()
    date = today.toLocaleDateString()
    time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds() + ":" + today.getMilliseconds()
    datetime = date + " " + time
    datetime_ms = Date.now()

    key = "#{tag.trail_index} - #{datetime} (#{tagName} #{type})"
    crumb = {
        short: type
        long: msg
        details: details
        datetime: datetime
        datetime_ms: datetime_ms
        tagName: tagName
    }

    ## track by tag
    if not tag.logs[tagName]?
        tag.logs[tagName] = {}
        tag.logs[tagName]["_all"] = {}

    if not tag.logs[tagName][type]?
        tag.logs[tagName][type] = {}
        tag.logs[tagName][type]['_length'] = 0

    tag.logs[tagName][type][key] = crumb
    tag.logs[tagName][type]['_length'] = Object.keys(tag.logs[tagName][type]).length - 1 ## for _length property
    tag.logs[tagName]["_all"][key] = crumb
    
    ## track by time
    tag.logs["_all"][key] = crumb
    
    tag.trail_index++
