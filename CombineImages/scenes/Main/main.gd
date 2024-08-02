extends Node2D

@onready var sprite1: Sprite2D = $Sprite1
@onready var sprite2: Sprite2D = $Sprite2
@onready var sprite3: Sprite2D = $Sprite3

var combined_sprite: Sprite2D = null


func _draw() -> void:
    draw_rect(calc_bounding_box([sprite1, sprite2, sprite3]), Color.LIGHT_BLUE, false, 10)

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


func combine_images() -> void:
    var format := sprite1.texture.get_image().get_format()
    var bounding_box := calc_bounding_box([sprite1, sprite2, sprite3])

    assert(format == sprite2.texture.get_image().get_format() and format == sprite3.texture.get_image().get_format())
    assert(bounding_box.size.x > 0 and bounding_box.size.y > 0)

    var image := Image.create(int(bounding_box.size.x), int(bounding_box.size.y), false, format)
    image.blit_rect(sprite1.texture.get_image(), Rect2i(Vector2i.ZERO, sprite1.texture.get_image().get_size()), get_sprite_rect(sprite1).position - bounding_box.position)
    image.blit_rect(sprite2.texture.get_image(), Rect2i(Vector2i.ZERO, sprite2.texture.get_image().get_size()), get_sprite_rect(sprite2).position - bounding_box.position)
    image.blit_rect(sprite3.texture.get_image(), Rect2i(Vector2i.ZERO, sprite3.texture.get_image().get_size()), get_sprite_rect(sprite3).position - bounding_box.position)

    var texture := ImageTexture.create_from_image(image)

    if combined_sprite:
        combined_sprite.queue_free()

    combined_sprite = Sprite2D.new()
    combined_sprite.texture = texture
    combined_sprite.position = Vector2(600, 300)
    add_child(combined_sprite)


func _on_button_pressed() -> void:
    combine_images()
    queue_redraw()
