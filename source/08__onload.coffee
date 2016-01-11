## crawl any changes to document.body
tagg.loaded = new Promise((loaded) =>
    document.addEventListener("DOMContentLoaded", (event) =>
        observer = new MutationObserver((mutations) =>
            for mutation in mutations
                for child in mutation.addedNodes
                    tagg.utils.crawl(child)
        )

        observer.observe(document.body, { 
            childList: true, 
            subtree: true
        })

        observer.observe(document.head, { 
            childList: true, 
            subtree: true
        })

        tagg.utils.crawl(document.body)

        loaded()

        tagg.update()
    )
)
