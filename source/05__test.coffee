tagg.trail_index = 0
tagg.logs = {
    _all: {}
    _verbose: {}
}


tagg.wrapTest = (test, delay=10) ->
    return new Promise((testsFinished) =>
        timeout = new Promise ((timeoutCompleted) =>
            tagg.loaded.then(() =>
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
                logs: tagg.logs
            }

            test(results)

            if results.failed.length is 0
                msg = " %c PASSED"
                for space in [0..Math.ceil(Math.random() * 10)]
                    msg = msg + " "
                console.log(msg, "color:blue;")
            else
                console.log("%c FAILED ", "background-color:red; color:white")
                console.log(results)

            testsFinished(results)
        )
    )


tagg.testEvent = (category, eventName, eventDetails) ->
    testingObj = {}
    testingObj[category] = {}
    testingObj[category][eventName] = eventDetails

    return tagg.testObj(testingObj)


tagg.testEvents = (events=[], delay=1000) ->
    testingObj = {}

    for event in events
        category = event[0]
        eventName = event[1]
        eventDetails = event[2]
        
        if not testingObj[category]?
            testingObj[category] = {}

        testingObj[category][eventName] = eventDetails
    
    return tagg.testObj(testingObj, delay)


tagg.testEqual = (arg1, arg2, msg='', delay=100) ->
    return tagg.wrapTest((results) =>
        if arg1 is arg2
            results.passed.push("#{arg1} equals #{arg2} for test #{msg}")
        else
            results.failed.push("#{arg1} does not equal #{arg2} for test #{msg}")
    , delay)


tagg.testAttr = (_tag, attrName, testVal, delay=100) ->
    return tagg.wrapTest((results) =>
        attrVal = _tag.getAttribute(attrName)
        tagName = _tag.tagName.toLowerCase()
        if testVal is attrVal
            results.passed.push("attr #{attrName} for #{tagName} equals #{testVal}")
        else
            results.failed.push("attr #{attrName} for #{tagName} does not equal #{testVal}, it equals #{attrVal}")
    , delay)


tagg.testProp = (_tag, propName, testVal, delay=100) ->
    return tagg.wrapTest((results) =>
        tagName = _tag.tagName.toLowerCase()
        if _tag[propName] is testVal
            results.passed.push("prop #{propName} for #{tagName} equals #{testVal}")
        else
            results.failed.push("prop #{propName} for #{tagName} does not equal #{testVal}, equals #{tag[propName]}")
    , delay)



tagg.testObj = (testingObj={}, delay=1000) ->
    return tagg.wrapTest((results) =>
        for category, tagCrumbs of testingObj
            if not tagg.logs[category]?
                results.failed.push("#{category} has had no events at all")
            else
                for eventType, eventTest of tagCrumbs
                    event = tagg.logs[category][eventType]
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
    , delay)


tagg.log = (type, category, verbose, details={}) =>
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

    key = "#{tagg.trail_index} #{time}: #{category} / #{type}"
    crumb = {
        short: type
        verbose: verbose
        details: if typeof details is "array" then details.toString() else details
        datetime: datetime
        datetime_ms: datetime_ms
        category: category
    }

    ## track by tag
    if not tagg.logs[category]?
        tagg.logs[category] = {}
        tagg.logs[category]["_all"] = {}
        tagg.logs[category]["_verbose"] = {}

    if not tagg.logs[category][type]?
        tagg.logs[category][type] = {}
        tagg.logs[category][type]['_length'] = 0

    tagg.logs[category][type][key] = crumb
    tagg.logs[category][type]['_length'] = Object.keys(tagg.logs[category][type]).length - 1 ## - 1 for _length property
    tagg.logs[category]["_all"][key] = crumb
    tagg.logs[category]["_verbose"][tagg.trail_index + " " + time] = verbose
    
    ## track by time
    tagg.logs["_all"][key] = crumb
    tagg.logs["_verbose"][tagg.trail_index + " " + time] = verbose
    
    tagg.trail_index++
