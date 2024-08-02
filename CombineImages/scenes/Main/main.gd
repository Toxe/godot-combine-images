extends Node2D

var combined_sprite: Sprite2D = null


func _draw() -> void:
    draw_rect(calc_bounding_box([$Sprite1, $Sprite2, $Sprite3]), Color.LIGHT_BLUE, false, 10)

    if combined_sprite:
        draw_rect(calc_bounding_box([combined_sprite]), Color.LIGHT_GREEN, false, 10)


func get_sprite_rect(sprite: Sprite2D) -> Rect2:
    var rect := Rect2(sprite.position + sprite.offset, sprite.get_rect().size)

    if sprite.centered:
        rect.position -= rect.size / 2

    return rect


func calc_bounding_box(sprites: Array[Sprite2D]) -> Rect2:
    assert(!sprites.is_empty())

    var bounding_box := get_sprite_rect(sprites[0])

    for i in range(1, sprites.size()):
        bounding_box = bounding_box.merge(get_sprite_rect(sprites[i]))

    return bounding_box


func combine_images(sprites: Array[Sprite2D]) -> void:
    assert(!sprites.is_empty())

    var format := sprites[0].texture.get_image().get_format()
    var bounding_box := calc_bounding_box(sprites)

    assert(sprites.all(func(sprite: Sprite2D) -> bool: return sprite.texture.get_image().get_format() == format))
    assert(bounding_box.size.x > 0 and bounding_box.size.y > 0)

    var image := Image.create(int(bounding_box.size.x), int(bounding_box.size.y), false, format)

    for sprite in sprites:
        image.blend_rect(sprite.texture.get_image(), Rect2i(Vector2i.ZERO, sprite.texture.get_image().get_size()), get_sprite_rect(sprite).position - bounding_box.position)

    var texture := ImageTexture.create_from_image(image)

    if combined_sprite:
        combined_sprite.queue_free()

    combined_sprite = Sprite2D.new()
    combined_sprite.texture = texture
    combined_sprite.position = Vector2(600, 300)
    add_child(combined_sprite)


func _on_button_pressed() -> void:
    combine_images([$Sprite1, $Sprite2, $Sprite3])
    queue_redraw()
