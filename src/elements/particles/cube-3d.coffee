Firecracker.register_particle('cube-3d', {

    properties:
        color: 'black'
        wireframe: false

    # flags:
        # wireframe: true

    create: () ->
        geometry = new THREE.BoxGeometry(@properties.width, @properties.height, @properties.depth)
        material = new THREE.MeshBasicMaterial({
            color: @properties.color,
            wireframe: @attributes.wireframe })
        instance = new THREE.Mesh( geometry, material )
        
        @shape = instance

})















# Polymer({

#     properties:
#         color: 'black'

#     flags:
#         wireframe: false

#     create: () ->
#         geometry = new THREE.BoxGeometry(@properties.w, @properties.h, @properties.d)
#         material = new THREE.MeshBasicMaterial({
#             color: @properties.color,
#             wireframe: @properties.wireframe })
#         instance = new THREE.Mesh( geometry, material )
        
#         @shape = instance

# })