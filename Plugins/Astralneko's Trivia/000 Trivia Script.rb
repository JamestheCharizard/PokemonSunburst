module AstralnekoTrivia
	def self.getQuestion(id)
		self.ensureCompiledData()
		return pbGetMessageFromHash(MessageTypes::AstralnekoTriviaQuestions, self.compiledData()[:questions][id.to_sym])
	end
	
	def self.getAnswers(id)
		self.ensureCompiledData()
		answerList = self.compiledData()[:answerLists][id.to_sym]
		answers = []
		for ans in answerList
			answers.push(pbGetMessageFromHash(MessageTypes::AstralnekoTriviaAnswers, ans))
		end
		return answers
	end
end


# Add trivia path to AstralnekoConfig
module AstralnekoConfig
	CORRECT_ANSWER_SPEECHES = [
		_INTL("\\xn[Leto]\\rNice! You got it right!")
	]
	INCORRECT_ANSWER_SPEECHES = [
		_INTL("\\xn[Leto]\\rAw... That's incorrect...")
	]
	TRIVIA_PATH = "PBS/default_trivia.txt" # DO NOT EDIT THIS
	TRIVIA_LOADING_LOG = true
end

# Ask a trivia question. Returns the user's correctness.
def anTriviaQuestion(id)
	# Select channel
	question = AstralnekoTrivia.getQuestion(id)
	answers = AstralnekoTrivia.getAnswers(id)
	correctAnswer = answers[0]
	correctAnswerId = 0
	answers.shuffle!
	for i in 0...answers.length
		if answers[i] == correctAnswer
			correctAnswerId = i
		end
	end
	cancelAnswer = -1
	chosen_answer = pbMessage(question, answers, cancelAnswer)
	case chosen_answer
		when -1
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
		when correctAnswerId
			pbMessage(AstralnekoConfig::CORRECT_ANSWER_SPEECHES.sample)
			return true
		else
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
	end
end

# Simulates asking an NPC a question.
def anTriviaQuestionToNPC(id,npc_name)
	# Select channel
	question = AstralnekoTrivia.getQuestion(id)
	answers = AstralnekoTrivia.getAnswers(id)
	correctAnswer = answers[0]
	correctAnswerId = 0
	answers.shuffle!
	for i in 0...answers.length
		if answers[i] == correctAnswer
			correctAnswerId = i
		end
	end
	cancelAnswer = -1
	full_question = question + " "
	for i in 0...answers.length
		full_question += answers[i]
		case answers.length - i
			when 1
				full_question += "."
			when 2
				full_question += " " + _INTL("or") + " "
			else
				full_question += ", "
		end
	end
	pbMessage(full_question)
	chosen_answer = rand(answers.length)
	pbMessage(_INTL("{1}: {2}?",npc_name,answers[chosen_answer]))
	case chosen_answer
		when -1
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
		when correctAnswerId
			pbMessage(AstralnekoConfig::CORRECT_ANSWER_SPEECHES.sample)
			return true
		else
			pbMessage(AstralnekoConfig::INCORRECT_ANSWER_SPEECHES.sample)
			return false
	end
end