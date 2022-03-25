"
I am a ProtocolLayer.  I implement my protocol as a state machine, transitioning from one state to another according to patterns that I recognise in the data flowing through me.
"
Class {
	#name : #StatefulProtocol,
	#superclass : #ProtocolLayer,
	#instVars : [
		'currentState',
		'client'
	],
	#category : #'Communications-Abstract'
}

{ #category : #'instance creation' }
StatefulProtocol class >> initialState: stateNode [

	^self new initialState: stateNode
]

{ #category : #'instance creation' }
StatefulProtocol class >> initialState: stateNode client: aClient [

	^self new initialState: stateNode; client: aClient
]

{ #category : #accessing }
StatefulProtocol >> client: anObject [

	client _ anObject
]

{ #category : #accessing }
StatefulProtocol >> initialState: stateNode [

	currentState _ stateNode.
	self client: self
]

{ #category : #accessing }
StatefulProtocol >> state [

	^currentState
]

{ #category : #protocol }
StatefulProtocol >> upcall: anObject [

	currentState _ (currentState transitionAt: anObject)
		transitionFrom: currentState for: client with: anObject
]
