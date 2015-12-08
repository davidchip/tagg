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

        console.log("debug log", tag.logs)
        loaded()

        tag.update()
    )
)
