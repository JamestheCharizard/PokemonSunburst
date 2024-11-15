def anPriceQuestion(list_of_items)
	return nil if !list_of_items
	if !list_of_items.is_a?(Array)
		items = [list_of_items]
	else
		items = list_of_items
	end
	# Get the actual cost of each item
	# Also organize the items by type, for displaying later
	total_price = 0
	organized_items = []
	items.each do |item|
		this_price = GameData::Item.get(item).price
		total_price += this_price
		hasBeenAdded = false
		organized_items.each do |item_set|
			if item_set[0] == item
				item_set[1]+=1
				hasBeenAdded = true
			end
		end
		if !hasBeenAdded
			organized_items.push([item,1])
		end
	end
	# Form complete item string from organized_items
	item_string = ""
	organized_items.each do |item_set|
		if item_set[1] == 1
			item_string += "1 " + GameData::Item.get(item_set[0]).name
		else
			item_string += item_set[1].to_s + " " + GameData::Item.get(item_set[0]).name_plural
		end
	end
	# Select channel
	question = _INTL("\\xn[Leto]\\rWhat's the price of {1}?",item_string)
	cancelAnswer = -1
	parameters = ChooseNumberParams.new
	parameters.setMaxDigits(6)
	parameters.setDefaultValue(0)
	parameters.setCancelValue(-1)
	chosen_answer = pbMessageChooseNumber(question, parameters)
	case chosen_answer
		when -1
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
		when total_price
			pbMessage(AstralnekoConfig::CORRECT_ANSWER_SPEECHES.sample)
			return true
		else
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
	end
end

def anPriceQuestionEx(*args)
	return nil if !args
	item_list = []
	previous_item = nil
	for item in args
		if item.is_a?(Symbol) # Item is a symbol for an item
			item_list.push(item)
			previous_item = item
		elsif item.is_a?(Integer) && previous_item # Item is a number of the previous item
			for i in 0..item-2 # -2 because 1. zero indexing, 2. it was already added to once by the previous set
				item_list.push(previous_item)
			end
		end
	end
	anPriceQuestion(item_list)
end