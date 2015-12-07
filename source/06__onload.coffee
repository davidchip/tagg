## crawl any changes to document.body
tag.loaded = new Promise((loaded) =>
    document.addEventListener("DOMContentLoaded", (event) =>
        observer = new MutationObserver((mutations) =>
            for mutation in mutations
                for child in mutation.addedNodes
                    tag.utils.crawl(child)
        )

        observer.observe(document.body, { 
            childList: true, 
            subtree: true
        })

        tag.utils.crawl(document.body)

        console.log("lifecycle logs", tag.logs)
        loaded()

        tag.frame = 0
        update = () ->
            requestAnimationFrame(update)

            for element in tag.updates
                element.update(tag.frame)

            tag.frame++

        update()

    )
)
