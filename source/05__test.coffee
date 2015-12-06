tag.trail_index = 0
tag.logs = {
    _all: {}
    _verbose: {}
}


tag.assertEvent = (category, eventName, eventDetails) ->
    testingObj = {}
    testingObj[category] = {}
    testingObj[category][eventName] = eventDetails
    return tag.assert(testingObj)


tag.assertEvents = (events=[], delay) ->
    testingObj = {}

    for event in events
        category = event[0]
        eventName = event[1]
        eventDetails = event[2]
        
        if not testingObj[category]?
            testingObj[category] = {}

        testingObj[category][eventName] = eventDetails
    
    return tag.assert(testingObj, delay)


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
            url = window.location.pathname;
            filename = url.substring(url.lastIndexOf('/')+1)

            results = {
                passed: []
                failed: []
                filename: filename
                logs: tag.logs
            }

            for category, tagCrumbs of testingObj
                if not tag.logs[category]?
                    results.failed.push("#{category} has had no events at all")
                else
                    for eventType, eventTest of tagCrumbs
                        event = tag.logs[category][eventType]
                        if not event?
                            results.failed.push("#{category} has had no events of type #{eventType}")
                        else
                            if typeof eventTest is "object"
                                for testKey, testValue of eventTest
                                    eventValue = event[testKey]
                                    if eventValue is testValue
                                        results.passed.push("#{category} had an event #{eventType} where #{testKey} equalled #{testValue}")
                                    else
                                        results.failed.push("#{category} had an event #{eventType} where #{testKey} equalled #{eventValue} instead of #{testValue}")
                            else if typeof eventTest is "function"
                                _eventTest = eventTest(event)
                                if _eventTest is true
                                    results.passed.push("#{category} function for #{eventType} passed")
                                else
                                    results.failed.push("#{category} function for #{eventType} failed")
                            else if typeof eventTest is "number"
                                if event["_length"] is eventTest
                                    testLength = 
                                    results.passed.push("#{category} had #{eventTest} instance(s) of #{eventType} event(s)")
                                else
                                    results.failed.push("#{category} had #{event["_length"]} instance(s) of #{eventType} being called, not #{eventTest}")
            
            if results.failed.length is 0
                console.log("\nPASSED\n", results, "\n\n")
            else
                console.log("\nFAILED\n", results, "\n\n")

            testsFinished(results)
        )
    )


tag.log = (type, category, verbose, details={}) =>
    """Add event regarding a category the central log.
    """
    if not verbose?
        verbose = type

    category = "#{category}"
    category = category.toLowerCase()
    today = new Date()
    date = today.toLocaleDateString()
    time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds() + ":" + today.getMilliseconds()
    datetime = date + " " + time
    datetime_ms = Date.now()

    key = "#{tag.trail_index} #{time}: #{category} / #{type}"
    crumb = {
        short: type
        verbose: verbose
        details: if typeof details is "array" then details.toString() else details
        datetime: datetime
        datetime_ms: datetime_ms
        category: category
    }

    ## track by tag
    if not tag.logs[category]?
        tag.logs[category] = {}
        tag.logs[category]["_all"] = {}
        tag.logs[category]["_verbose"] = {}

    if not tag.logs[category][type]?
        tag.logs[category][type] = {}
        tag.logs[category][type]['_length'] = 0

    tag.logs[category][type][key] = crumb
    tag.logs[category][type]['_length'] = Object.keys(tag.logs[category][type]).length - 1 ## - 1 for _length property
    tag.logs[category]["_all"][key] = crumb
    tag.logs[category]["_verbose"][tag.trail_index + " " + time] = verbose
    
    ## track by time
    tag.logs["_all"][key] = crumb
    tag.logs["_verbose"][tag.trail_index + " " + time] = verbose
    
    tag.trail_index++