extends Control

signal opened
signal closed 

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://inventory/playerInventory.tres")
@onready var itemStackGuiClass = preload("res://gui/itemsStackGui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var itemInHand: ItemStackGui
var oldIndex: int = -1
var locked: bool = false

func _ready():
	connectSlots()
	inventory.updated.connect(update)
	update()
	
func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = itemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
	
		itemStackGui.inventorySlot = inventorySlot
		itemStackGui.update()

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()

func onSlotClicked(slot):
	if locked: return 
	
	if slot.isEmpty():
		if !itemInHand: return 
		insertItemInSlot(slot)
		return
	
	if !itemInHand:
		takeItemFromSlot(slot)
		return
	
	if slot.itemStackGui.inventorySlot.item.name == itemInHand.inventorySlot.item.name:
		stackItems(slot)
		return
		
	swapItems(slot)

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index

func insertItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	insertItemInSlot(slot)
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()
	
func stackItems(slot):
	print_debug("hej")
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.inventorySlot.item.maxAmountPrStack
	var totalAmount = slotItem.inventorySlot.amount + itemInHand.inventorySlot.amount
	if slotItem.inventorySlot.amount == maxAmount:
		swapItems(slot)
		return
	if totalAmount <= maxAmount:
		slotItem.inventorySlot.amount = totalAmount
		remove_child(itemInHand)
		itemInHand = null
		oldIndex = -1
	if totalAmount > maxAmount:
		slotItem.inventorySlot.amount = maxAmount
		itemInHand.inventorySlot.amount = totalAmount - maxAmount
	
	slotItem.update()
	if itemInHand: itemInHand.update()
	
func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func putItemBack():
	locked = true
	if oldIndex < 0:
		var emptySlot = slots.filter(func (s): return s.isEmpty())
		if emptySlot.is_empty(): return
		oldIndex = emptySlot[0].index
	var targetSlot = slots[oldIndex]
	var tween = create_tween()
	var targetPosition = targetSlot.global_position + targetSlot.size / 2
	tween.tween_property(itemInHand, "global_position", targetPosition, 0.1)
	await tween.finished
	insertItemInSlot(targetSlot)
	locked = false

func _input(event):
	if itemInHand && !locked && Input.is_action_just_pressed("rightClick"):
		putItemBack()
	updateItemInHand()
