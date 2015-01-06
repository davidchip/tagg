Firecracker.register_particle('model-3d', {

    wireframe: false

    create: () ->
     
        colonial_city = Firecracker.ObjectUtils.load3DModel(
        	"Maps/sirus_city.js", 
        	new THREE.MeshNormalMaterial(), 
        	window.world
        )

        return colonial_city

})