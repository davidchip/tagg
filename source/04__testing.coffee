tag.trail_index = 0
tag.logs = {
    _all: {}
    _verbose: {}
}


tag.assertEvent = (tagName, eventName, eventDetails) ->
    testingObj = {}
    testingObj[tagName] = {}
    testingObj[tagName][eventName] = eventDetails
    return tag.assert(testingObj)


tag.assertEvents = (events=[]) ->
    testingObj = {}

    for event in events
        tagName = event[0]
        eventName = event[1]
        eventDetails = event[2]
        
        if not testingObj[tagName]?
            testingObj[tagName] = {}

        testingObj[tagName][eventName] = eventDetails
    
    return tag.assert(testingObj)


tag.assert = (testingObj={}, delay=1000) ->
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
                    results.failed.push("#{tagName} has had no events at all")
                else
                    for eventType, eventTest of tagCrumbs
                        event = tag.logs[tagName][eventType]
                        if not event?
                            results.failed.push("#{tagName} has had no events of type #{eventType}")
                        else
                            if typeof eventTest is "object"
                                for testKey, testValue of eventTest
                                    eventValue = event[testKey]
                                    if eventValue is testValue
                                        results.passed.push("#{tagName} had an event #{eventType} where #{testKey} equalled #{testValue}")
                                    else
                                        results.failed.push("#{tagName} had an event #{eventType} where #{testKey} equalled #{eventValue} instead of #{testValue}")
                            else if typeof eventTest is "function"
                                _eventTest = eventTest(event)
                                if _eventTest is true
                                    results.passed.push("#{tagName} function for #{eventType} passed")
                                else
                                    results.failed.push("#{tagName} function for #{eventType} failed")
                            else if typeof eventTest is "number"
                                if event["_length"] is eventTest
                                    testLength = 
                                    results.passed.push("#{tagName} had #{eventTest} instance(s) of #{eventType} event(s)")
                                else
                                    results.failed.push("#{tagName} had #{event["_length"]} instance(s) of #{eventType} being called, not #{eventTest}")

            if results.failed.length is 0
                console.log("test(s) passed", results)
            else
                console.log("test(s) failed", results)

            testsFinished(results)
        )
    )


tag.log = (type, tagName, verbose, details={}) =>
    """Add event regarding a tagName the central log.
    """
    tagName = tagName.toLowerCase()
    today = new Date()
    date = today.toLocaleDateString()
    time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds() + ":" + today.getMilliseconds()
    datetime = date + " " + time
    datetime_ms = Date.now()

    key = "#{tag.trail_index} #{time}: #{tagName} / #{type}"
    crumb = {
        short: type
        verbose: verbose
        details: if typeof details is "array" then details.toString() else details
        datetime: datetime
        datetime_ms: datetime_ms
        tagName: tagName
    }

    ## track by tag
    if not tag.logs[tagName]?
        tag.logs[tagName] = {}
        tag.logs[tagName]["_all"] = {}
        tag.logs[tagName]["_verbose"] = {}

    if not tag.logs[tagName][type]?
        tag.logs[tagName][type] = {}
        tag.logs[tagName][type]['_length'] = 0

    tag.logs[tagName][type][key] = crumb
    tag.logs[tagName][type]['_length'] = Object.keys(tag.logs[tagName][type]).length - 1 ## - 1 for _length property
    tag.logs[tagName]["_all"][key] = crumb
    tag.logs[tagName]["_verbose"][tag.trail_index + " " + time] = verbose
    
    ## track by time
    tag.logs["_all"][key] = crumb
    tag.logs["_verbose"][tag.trail_index + " " + time] = verbose
    
    tag.trail_index++
