Class {
	#name : #SBBashFormattedTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'pty',
		'closed'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> absorbsInput: anEvent [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> addBashOutput: aBuffer [

	| output |
	output := '' asText.
	self readFrom: aBuffer asString readStream writeInto: output.
	Project current addDeferredUIMessage: (self contents: self contents asText, aBuffer)
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> colorFrom: parameter [

	parameter = '30' ifTrue: [^ TextColor black].
	parameter = '31' ifTrue: [^ TextColor red].
	parameter = '32' ifTrue: [^ TextColor green].
	parameter = '33' ifTrue: [^ TextColor yellow].
	parameter = '34' ifTrue: [^ TextColor blue].
	parameter = '35' ifTrue: [^ TextColor magenta].
	parameter = '36' ifTrue: [^ TextColor cyan].
	parameter = '37' ifTrue: [^ TextColor white].
	parameter = '90' ifTrue: [^ TextColor gray].
	parameter = '91' ifTrue: [^ TextColor red].
	parameter = '92' ifTrue: [^ TextColor green].
	parameter = '93' ifTrue: [^ TextColor yellow].
	parameter = '94' ifTrue: [^ TextColor blue].
	parameter = '95' ifTrue: [^ TextColor magenta].
	parameter = '96' ifTrue: [^ TextColor cyan].
	parameter = '97' ifTrue: [^ TextColor white].
	^ TextColor black
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> initialize [

	super initialize
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> readFrom: input writeInto: output [

	| state sequence color |
	state := #read.
	color := TextColor black.
	[input atEnd] whileFalse: [
		state = #escape ifTrue: [
			sequence := input upToAnyOf: #($; $m).
			"color"
			
			sequence = '[01' ifTrue: [
				color := self colorFrom: (input upTo: $m).
				state := #read].
			"reset all attributes"
			(sequence = '[00' or: sequence = '[0') ifTrue: [
				color := TextColor black.
				state := #read].
			"set title"
			sequence = ']0' ifTrue: [ | title |
				title := input upTo: (Character value: 7).
				state := #read]].
		input peek = Character escape ifTrue: [
			state := #escape.
			input next].
		state = #read ifTrue: [
			output append: ((input upTo: Character escape) asText
				addAttribute: color;
				addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
			state := #escape]]
]
