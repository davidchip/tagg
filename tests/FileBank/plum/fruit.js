this.define("plum-fruit", {
    size: 10,
    created: function () {
        this.style.top = Math.random() * 100 + "%";
        this.style.left = Math.random() * 100 + "%";
    },
    update: function (frame) {
        if (frame % 50 == 0) {
            this.style.top = Math.random() * 100 + "%";
            this.style.left = Math.random() * 100 + "%";
        }
    }
});
