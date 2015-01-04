Firecracker.register_particle('cube-3d', {

    _properties:
        color: 'black'
        wireframe: false

    create: () ->
        geometry = new THREE.BoxGeometry(@width, @height, @depth)
        material = new THREE.MeshBasicMaterial({color:@color, wireframe:@wireframe})
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