Firecracker.register_particle('world-sea', {

    extends: 'world-core'

    create: () ->
        skydome = Firecracker.ObjectUtils.skyDome("/assets/sea_sky.jpg")
        window.world.add(skydome)  

})