Class {
	#name : #SBBashInput,
	#superclass : #SBBash,
	#instVars : [
		'terminal',
		'current',
		'processReturn'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInput class >> autocompleteFile [
	<action>
	<actionValidIf: #canAutocompleteFile:>

	UIManager default inform: 'please first implement autocompletion'
]

{ #category : #'as yet unclassified' }
SBBashInput class >> canAutocompleteFile: aBlock [

	^ aBlock type = #word and: [aBlock sandblockEditor suggestionMenu canUseSuggestion not]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> confirm: aBlock [
	<action>

	| pty terminal command |
	terminal := aBlock containingArtefact.
	command := (aBlock orOwnerSuchThat: [:b | b isTSBlock and: [b type = #command]]) ifNotNil: #sourceString ifNil: [^ self].
	pty := terminal pty.
	terminal state: #hidden.
	terminal waitingForCommandString: command.
	pty nextPutAll: command.
	pty nextPut: Character return
]

{ #category : #'as yet unclassified' }
SBBashInput class >> deduplicateBashSuggestions: aCollection [

	| dict deduplicationDict sizesDict suggestionDict uniqSuggs uniqGroups |
	dict := aCollection groupBy: [:suggestion | suggestion key].
	sizesDict := dict collect: [:c | c value size].
	suggestionDict := dict collect: [:c | c value first].
	SBToggledCode
		comment: ''
		active: 0
		do: {[orderedDict := dict withKeysSorted: [:k1 :k2 | (sizesDict at: k1) >= (sizesDict at: k2)]]}.
	uniqSuggs := OrderedCollection new.
	SBToggledCode comment: '' active: 0 do: {
		[orderedDict keysDo: [:c | deduplicatedSuggestions add: ((suggestionDict at: c) option: (sizesDict at: c) printString)]]}.
	
	deduplicationDict := OrderedDictionary new.
	aCollection reverseDo: [:suggestion | deduplicationDict at: suggestion key put: suggestion].
	uniqSuggs := deduplicationDict keys reverse.
	uniqGroups := OrderedCollection new.
	uniqSuggs do: [:c | | uniqueSuggestion moreOptions |
		uniqueSuggestion := suggestionDict at: c.
		moreOptions := (sizesDict at: c) - 1.
		moreOptions > 0 ifTrue: [uniqueSuggestion selector: moreOptions printString, ' more option(s)'].
		uniqGroups add: uniqueSuggestion].
	^ uniqGroups
]

{ #category : #'as yet unclassified' }
SBBashInput class >> getSuggestionFromCommand: aCommandObject in: anEditor [

	| selector upto contents |
	selector := aCommandObject commandName.
	selector size > 100 ifTrue: [selector := (selector from: 1 to: 97), '...'].
	upto := (aCommandObject commandString findString: ' ') - 1.
	upto < 0 ifTrue: [upto := aCommandObject commandString size].
	contents := aCommandObject commandString from: 1 to: upto.
	^ SBBashTSBlockSuggestion new
		selector: selector;
		blocks: {
				(self blockFor: #word)
					contents: contents;
					yourself}
			in: anEditor;
		option: aCommandObject commandString;
		key: contents
]

{ #category : #'as yet unclassified' }
SBBashInput class >> grammarJson [
	" https://github.com/bash/blob/master/src/grammar.json "

	^ '{
  "name": "bash",
  "word": "word",
  "rules": {
    "program": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_statements"
        },
        {
          "type": "BLANK"
        }
      ]
    },
    "_statements": {
      "type": "PREC",
      "value": 1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "REPEAT",
            "content": {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "_statement"
                },
                {
                  "type": "SYMBOL",
                  "name": "_terminator"
                }
              ]
            }
          },
          {
            "type": "SYMBOL",
            "name": "_statement"
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "STRING",
                    "value": "\n"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "heredoc_body"
                  }
                ]
              },
              {
                "type": "BLANK"
              }
            ]
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_terminator"
              },
              {
                "type": "BLANK"
              }
            ]
          }
        ]
      }
    },
    "_statements2": {
      "type": "REPEAT1",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "_statement"
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "STRING",
                    "value": "\n"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "heredoc_body"
                  }
                ]
              },
              {
                "type": "BLANK"
              }
            ]
          },
          {
            "type": "SYMBOL",
            "name": "_terminator"
          }
        ]
      }
    },
    "_terminated_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_statement"
        },
        {
          "type": "SYMBOL",
          "name": "_terminator"
        }
      ]
    },
    "_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "redirected_statement"
        },
        {
          "type": "SYMBOL",
          "name": "variable_assignment"
        },
        {
          "type": "SYMBOL",
          "name": "command"
        },
        {
          "type": "SYMBOL",
          "name": "declaration_command"
        },
        {
          "type": "SYMBOL",
          "name": "unset_command"
        },
        {
          "type": "SYMBOL",
          "name": "test_command"
        },
        {
          "type": "SYMBOL",
          "name": "negated_command"
        },
        {
          "type": "SYMBOL",
          "name": "for_statement"
        },
        {
          "type": "SYMBOL",
          "name": "c_style_for_statement"
        },
        {
          "type": "SYMBOL",
          "name": "while_statement"
        },
        {
          "type": "SYMBOL",
          "name": "if_statement"
        },
        {
          "type": "SYMBOL",
          "name": "case_statement"
        },
        {
          "type": "SYMBOL",
          "name": "pipeline"
        },
        {
          "type": "SYMBOL",
          "name": "list"
        },
        {
          "type": "SYMBOL",
          "name": "subshell"
        },
        {
          "type": "SYMBOL",
          "name": "compound_statement"
        },
        {
          "type": "SYMBOL",
          "name": "function_definition"
        }
      ]
    },
    "redirected_statement": {
      "type": "PREC",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "body",
            "content": {
              "type": "SYMBOL",
              "name": "_statement"
            }
          },
          {
            "type": "FIELD",
            "name": "redirect",
            "content": {
              "type": "REPEAT1",
              "content": {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "file_redirect"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "heredoc_redirect"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "herestring_redirect"
                  }
                ]
              }
            }
          }
        ]
      }
    },
    "for_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "for"
            },
            {
              "type": "STRING",
              "value": "select"
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "variable",
          "content": {
            "type": "SYMBOL",
            "name": "_simple_variable_name"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "in"
                },
                {
                  "type": "FIELD",
                  "name": "value",
                  "content": {
                    "type": "REPEAT1",
                    "content": {
                      "type": "SYMBOL",
                      "name": "_literal"
                    }
                  }
                }
              ]
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "SYMBOL",
          "name": "_terminator"
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "do_group"
          }
        }
      ]
    },
    "c_style_for_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "for"
        },
        {
          "type": "STRING",
          "value": "(("
        },
        {
          "type": "FIELD",
          "name": "initializer",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_expression"
              },
              {
                "type": "BLANK"
              }
            ]
          }
        },
        {
          "type": "SYMBOL",
          "name": "_terminator"
        },
        {
          "type": "FIELD",
          "name": "condition",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_expression"
              },
              {
                "type": "BLANK"
              }
            ]
          }
        },
        {
          "type": "SYMBOL",
          "name": "_terminator"
        },
        {
          "type": "FIELD",
          "name": "update",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_expression"
              },
              {
                "type": "BLANK"
              }
            ]
          }
        },
        {
          "type": "STRING",
          "value": "))"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": ";"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "do_group"
              },
              {
                "type": "SYMBOL",
                "name": "compound_statement"
              }
            ]
          }
        }
      ]
    },
    "while_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "while"
            },
            {
              "type": "STRING",
              "value": "until"
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "condition",
          "content": {
            "type": "SYMBOL",
            "name": "_terminated_statement"
          }
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "do_group"
          }
        }
      ]
    },
    "do_group": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "do"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements2"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "done"
        }
      ]
    },
    "if_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "if"
        },
        {
          "type": "FIELD",
          "name": "condition",
          "content": {
            "type": "SYMBOL",
            "name": "_terminated_statement"
          }
        },
        {
          "type": "STRING",
          "value": "then"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements2"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "elif_clause"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "else_clause"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "fi"
        }
      ]
    },
    "elif_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "elif"
        },
        {
          "type": "SYMBOL",
          "name": "_terminated_statement"
        },
        {
          "type": "STRING",
          "value": "then"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements2"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "else_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "else"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements2"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "case_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "case"
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_literal"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_terminator"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "in"
        },
        {
          "type": "SYMBOL",
          "name": "_terminator"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "REPEAT",
                  "content": {
                    "type": "SYMBOL",
                    "name": "case_item"
                  }
                },
                {
                  "type": "ALIAS",
                  "content": {
                    "type": "SYMBOL",
                    "name": "last_case_item"
                  },
                  "named": true,
                  "value": "case_item"
                }
              ]
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "esac"
        }
      ]
    },
    "case_item": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_literal"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "|"
              },
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_literal"
                }
              }
            ]
          }
        },
        {
          "type": "STRING",
          "value": ")"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "PREC",
          "value": 1,
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "termination",
                "content": {
                  "type": "STRING",
                  "value": ";;"
                }
              },
              {
                "type": "FIELD",
                "name": "fallthrough",
                "content": {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "STRING",
                      "value": ";&"
                    },
                    {
                      "type": "STRING",
                      "value": ";;&"
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    },
    "last_case_item": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_literal"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "|"
              },
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_literal"
                }
              }
            ]
          }
        },
        {
          "type": "STRING",
          "value": ")"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "PREC",
              "value": 1,
              "content": {
                "type": "STRING",
                "value": ";;"
              }
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "function_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "function"
                },
                {
                  "type": "FIELD",
                  "name": "name",
                  "content": {
                    "type": "SYMBOL",
                    "name": "word"
                  }
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "STRING",
                          "value": "("
                        },
                        {
                          "type": "STRING",
                          "value": ")"
                        }
                      ]
                    },
                    {
                      "type": "BLANK"
                    }
                  ]
                }
              ]
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "FIELD",
                  "name": "name",
                  "content": {
                    "type": "SYMBOL",
                    "name": "word"
                  }
                },
                {
                  "type": "STRING",
                  "value": "("
                },
                {
                  "type": "STRING",
                  "value": ")"
                }
              ]
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "compound_statement"
              },
              {
                "type": "SYMBOL",
                "name": "subshell"
              },
              {
                "type": "SYMBOL",
                "name": "test_command"
              }
            ]
          }
        }
      ]
    },
    "compound_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_statements2"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "subshell": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "SYMBOL",
          "name": "_statements"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "pipeline": {
      "type": "PREC_LEFT",
      "value": 1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "_statement"
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "|"
              },
              {
                "type": "STRING",
                "value": "|&"
              }
            ]
          },
          {
            "type": "SYMBOL",
            "name": "_statement"
          }
        ]
      }
    },
    "list": {
      "type": "PREC_LEFT",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "_statement"
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "&&"
              },
              {
                "type": "STRING",
                "value": "||"
              }
            ]
          },
          {
            "type": "SYMBOL",
            "name": "_statement"
          }
        ]
      }
    },
    "negated_command": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "!"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "command"
            },
            {
              "type": "SYMBOL",
              "name": "test_command"
            },
            {
              "type": "SYMBOL",
              "name": "subshell"
            }
          ]
        }
      ]
    },
    "test_command": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "["
                },
                {
                  "type": "SYMBOL",
                  "name": "_expression"
                },
                {
                  "type": "STRING",
                  "value": "]"
                }
              ]
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "[["
                },
                {
                  "type": "SYMBOL",
                  "name": "_expression"
                },
                {
                  "type": "STRING",
                  "value": "]]"
                }
              ]
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "(("
                },
                {
                  "type": "SYMBOL",
                  "name": "_expression"
                },
                {
                  "type": "STRING",
                  "value": "))"
                }
              ]
            }
          ]
        }
      ]
    },
    "declaration_command": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "declare"
              },
              {
                "type": "STRING",
                "value": "typeset"
              },
              {
                "type": "STRING",
                "value": "export"
              },
              {
                "type": "STRING",
                "value": "readonly"
              },
              {
                "type": "STRING",
                "value": "local"
              }
            ]
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "_literal"
                },
                {
                  "type": "SYMBOL",
                  "name": "_simple_variable_name"
                },
                {
                  "type": "SYMBOL",
                  "name": "variable_assignment"
                }
              ]
            }
          }
        ]
      }
    },
    "unset_command": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "unset"
              },
              {
                "type": "STRING",
                "value": "unsetenv"
              }
            ]
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "_literal"
                },
                {
                  "type": "SYMBOL",
                  "name": "_simple_variable_name"
                }
              ]
            }
          }
        ]
      }
    },
    "command": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "REPEAT",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "variable_assignment"
                },
                {
                  "type": "SYMBOL",
                  "name": "file_redirect"
                }
              ]
            }
          },
          {
            "type": "FIELD",
            "name": "name",
            "content": {
              "type": "SYMBOL",
              "name": "command_name"
            }
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "FIELD",
              "name": "argument",
              "content": {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "_literal"
                  },
                  {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "STRING",
                            "value": "=~"
                          },
                          {
                            "type": "STRING",
                            "value": "=="
                          }
                        ]
                      },
                      {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "SYMBOL",
                            "name": "_literal"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "regex"
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
        ]
      }
    },
    "command_name": {
      "type": "SYMBOL",
      "name": "_literal"
    },
    "variable_assignment": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "name",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "variable_name"
              },
              {
                "type": "SYMBOL",
                "name": "subscript"
              }
            ]
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "="
            },
            {
              "type": "STRING",
              "value": "+="
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_literal"
              },
              {
                "type": "SYMBOL",
                "name": "array"
              },
              {
                "type": "SYMBOL",
                "name": "_empty_value"
              }
            ]
          }
        }
      ]
    },
    "subscript": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "name",
          "content": {
            "type": "SYMBOL",
            "name": "variable_name"
          }
        },
        {
          "type": "STRING",
          "value": "["
        },
        {
          "type": "FIELD",
          "name": "index",
          "content": {
            "type": "SYMBOL",
            "name": "_literal"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_concat"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "]"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_concat"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "file_redirect": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "descriptor",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "file_descriptor"
                },
                {
                  "type": "BLANK"
                }
              ]
            }
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "<"
              },
              {
                "type": "STRING",
                "value": ">"
              },
              {
                "type": "STRING",
                "value": ">>"
              },
              {
                "type": "STRING",
                "value": "&>"
              },
              {
                "type": "STRING",
                "value": "&>>"
              },
              {
                "type": "STRING",
                "value": "<&"
              },
              {
                "type": "STRING",
                "value": ">&"
              },
              {
                "type": "STRING",
                "value": ">|"
              }
            ]
          },
          {
            "type": "FIELD",
            "name": "destination",
            "content": {
              "type": "SYMBOL",
              "name": "_literal"
            }
          }
        ]
      }
    },
    "heredoc_redirect": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "<<"
            },
            {
              "type": "STRING",
              "value": "<<-"
            }
          ]
        },
        {
          "type": "SYMBOL",
          "name": "heredoc_start"
        }
      ]
    },
    "heredoc_body": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_simple_heredoc_body"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_heredoc_body_beginning"
            },
            {
              "type": "REPEAT",
              "content": {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "expansion"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "simple_expansion"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "command_substitution"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "_heredoc_body_middle"
                  }
                ]
              }
            },
            {
              "type": "SYMBOL",
              "name": "_heredoc_body_end"
            }
          ]
        }
      ]
    },
    "herestring_redirect": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "<<<"
        },
        {
          "type": "SYMBOL",
          "name": "_literal"
        }
      ]
    },
    "_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_literal"
        },
        {
          "type": "SYMBOL",
          "name": "unary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "ternary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "binary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "postfix_expression"
        },
        {
          "type": "SYMBOL",
          "name": "parenthesized_expression"
        }
      ]
    },
    "binary_expression": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "_expression"
                }
              },
              {
                "type": "FIELD",
                "name": "operator",
                "content": {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "STRING",
                      "value": "="
                    },
                    {
                      "type": "STRING",
                      "value": "=="
                    },
                    {
                      "type": "STRING",
                      "value": "=~"
                    },
                    {
                      "type": "STRING",
                      "value": "!="
                    },
                    {
                      "type": "STRING",
                      "value": "+"
                    },
                    {
                      "type": "STRING",
                      "value": "-"
                    },
                    {
                      "type": "STRING",
                      "value": "+="
                    },
                    {
                      "type": "STRING",
                      "value": "-="
                    },
                    {
                      "type": "STRING",
                      "value": "<"
                    },
                    {
                      "type": "STRING",
                      "value": ">"
                    },
                    {
                      "type": "STRING",
                      "value": "<="
                    },
                    {
                      "type": "STRING",
                      "value": ">="
                    },
                    {
                      "type": "STRING",
                      "value": "||"
                    },
                    {
                      "type": "STRING",
                      "value": "&&"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "test_operator"
                    }
                  ]
                }
              },
              {
                "type": "FIELD",
                "name": "right",
                "content": {
                  "type": "SYMBOL",
                  "name": "_expression"
                }
              }
            ]
          },
          {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "_expression"
                }
              },
              {
                "type": "FIELD",
                "name": "operator",
                "content": {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "STRING",
                      "value": "=="
                    },
                    {
                      "type": "STRING",
                      "value": "=~"
                    }
                  ]
                }
              },
              {
                "type": "FIELD",
                "name": "right",
                "content": {
                  "type": "SYMBOL",
                  "name": "regex"
                }
              }
            ]
          }
        ]
      }
    },
    "ternary_expression": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "condition",
            "content": {
              "type": "SYMBOL",
              "name": "_expression"
            }
          },
          {
            "type": "STRING",
            "value": "?"
          },
          {
            "type": "FIELD",
            "name": "consequence",
            "content": {
              "type": "SYMBOL",
              "name": "_expression"
            }
          },
          {
            "type": "STRING",
            "value": ":"
          },
          {
            "type": "FIELD",
            "name": "alternative",
            "content": {
              "type": "SYMBOL",
              "name": "_expression"
            }
          }
        ]
      }
    },
    "unary_expression": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "!"
              },
              {
                "type": "SYMBOL",
                "name": "test_operator"
              }
            ]
          },
          {
            "type": "SYMBOL",
            "name": "_expression"
          }
        ]
      }
    },
    "postfix_expression": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_expression"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "++"
            },
            {
              "type": "STRING",
              "value": "--"
            }
          ]
        }
      ]
    },
    "parenthesized_expression": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "SYMBOL",
          "name": "_expression"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "_literal": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "concatenation"
        },
        {
          "type": "SYMBOL",
          "name": "_primary_expression"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "PREC",
            "value": -2,
            "content": {
              "type": "REPEAT1",
              "content": {
                "type": "SYMBOL",
                "name": "_special_character"
              }
            }
          },
          "named": true,
          "value": "word"
        }
      ]
    },
    "_primary_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "flag"
        },
        {
          "type": "SYMBOL",
          "name": "word"
        },
        {
          "type": "SYMBOL",
          "name": "string"
        },
        {
          "type": "SYMBOL",
          "name": "raw_string"
        },
        {
          "type": "SYMBOL",
          "name": "ansii_c_string"
        },
        {
          "type": "SYMBOL",
          "name": "expansion"
        },
        {
          "type": "SYMBOL",
          "name": "simple_expansion"
        },
        {
          "type": "SYMBOL",
          "name": "string_expansion"
        },
        {
          "type": "SYMBOL",
          "name": "command_substitution"
        },
        {
          "type": "SYMBOL",
          "name": "process_substitution"
        }
      ]
    },
    "flag": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_flag_start"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "flag_argument"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "concatenation": {
      "type": "PREC",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "_primary_expression"
              },
              {
                "type": "SYMBOL",
                "name": "_special_character"
              }
            ]
          },
          {
            "type": "REPEAT1",
            "content": {
              "type": "PREC",
              "value": -1,
              "content": {
                "type": "SEQ",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "_concat"
                  },
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "SYMBOL",
                        "name": "_primary_expression"
                      },
                      {
                        "type": "SYMBOL",
                        "name": "_special_character"
                      }
                    ]
                  }
                ]
              }
            }
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "_concat"
                  },
                  {
                    "type": "STRING",
                    "value": "$"
                  }
                ]
              },
              {
                "type": "BLANK"
              }
            ]
          }
        ]
      }
    },
    "_special_character": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": -1,
        "content": {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "{"
            },
            {
              "type": "STRING",
              "value": "}"
            },
            {
              "type": "STRING",
              "value": "["
            },
            {
              "type": "STRING",
              "value": "]"
            }
          ]
        }
      }
    },
    "string": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "\""
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "STRING",
                            "value": "$"
                          },
                          {
                            "type": "BLANK"
                          }
                        ]
                      },
                      {
                        "type": "SYMBOL",
                        "name": "_string_content"
                      }
                    ]
                  },
                  {
                    "type": "SYMBOL",
                    "name": "expansion"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "simple_expansion"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "command_substitution"
                  }
                ]
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "_concat"
                  },
                  {
                    "type": "BLANK"
                  }
                ]
              }
            ]
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "$"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "\""
        }
      ]
    },
    "_string_content": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": -1,
        "content": {
          "type": "PATTERN",
          "value": "([^\"`$\\\\]|\\\\(.|\\r?\\n))+"
        }
      }
    },
    "array": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_literal"
          }
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "raw_string": {
      "type": "PATTERN",
      "value": "''[^'']*''"
    },
    "ansii_c_string": {
      "type": "PATTERN",
      "value": "\\$''([^'']|\\\\'')*''"
    },
    "simple_expansion": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "$"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_simple_variable_name"
            },
            {
              "type": "SYMBOL",
              "name": "_special_variable_name"
            },
            {
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "!"
              },
              "named": true,
              "value": "special_variable_name"
            },
            {
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "#"
              },
              "named": true,
              "value": "special_variable_name"
            }
          ]
        }
      ]
    },
    "string_expansion": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "$"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "string"
            },
            {
              "type": "SYMBOL",
              "name": "raw_string"
            }
          ]
        }
      ]
    },
    "expansion_flags": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "PATTERN",
            "value": "[^()]"
          }
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "expansion": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "${"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "expansion_flags"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "CHOICE",
              "members": [
                {
                  "type": "STRING",
                  "value": "#"
                },
                {
                  "type": "STRING",
                  "value": "!"
                }
              ]
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "variable_name"
                    },
                    {
                      "type": "STRING",
                      "value": "="
                    },
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "SYMBOL",
                          "name": "_literal"
                        },
                        {
                          "type": "BLANK"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "SYMBOL",
                          "name": "subscript"
                        },
                        {
                          "type": "SYMBOL",
                          "name": "_simple_variable_name"
                        },
                        {
                          "type": "SYMBOL",
                          "name": "_special_variable_name"
                        }
                      ]
                    },
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "SEQ",
                          "members": [
                            {
                              "type": "TOKEN",
                              "content": {
                                "type": "PREC",
                                "value": 1,
                                "content": {
                                  "type": "STRING",
                                  "value": "/"
                                }
                              }
                            },
                            {
                              "type": "CHOICE",
                              "members": [
                                {
                                  "type": "SYMBOL",
                                  "name": "regex"
                                },
                                {
                                  "type": "BLANK"
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "type": "BLANK"
                        }
                      ]
                    },
                    {
                      "type": "REPEAT",
                      "content": {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "SYMBOL",
                            "name": "_literal"
                          },
                          {
                            "type": "STRING",
                            "value": ":"
                          },
                          {
                            "type": "STRING",
                            "value": ":?"
                          },
                          {
                            "type": "STRING",
                            "value": "="
                          },
                          {
                            "type": "STRING",
                            "value": ":-"
                          },
                          {
                            "type": "STRING",
                            "value": "%"
                          },
                          {
                            "type": "STRING",
                            "value": "-"
                          },
                          {
                            "type": "STRING",
                            "value": "#"
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "command_substitution": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "STRING",
              "value": "$("
            },
            {
              "type": "SYMBOL",
              "name": "_statements"
            },
            {
              "type": "STRING",
              "value": ")"
            }
          ]
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "STRING",
              "value": "$("
            },
            {
              "type": "SYMBOL",
              "name": "file_redirect"
            },
            {
              "type": "STRING",
              "value": ")"
            }
          ]
        },
        {
          "type": "PREC",
          "value": 1,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "`"
              },
              {
                "type": "SYMBOL",
                "name": "_statements"
              },
              {
                "type": "STRING",
                "value": "`"
              }
            ]
          }
        }
      ]
    },
    "process_substitution": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "<("
            },
            {
              "type": "STRING",
              "value": ">("
            }
          ]
        },
        {
          "type": "SYMBOL",
          "name": "_statements"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "comment": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": -10,
        "content": {
          "type": "PATTERN",
          "value": "#.*"
        }
      }
    },
    "_simple_variable_name": {
      "type": "ALIAS",
      "content": {
        "type": "PATTERN",
        "value": "\\w+"
      },
      "named": true,
      "value": "variable_name"
    },
    "_special_variable_name": {
      "type": "ALIAS",
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "STRING",
            "value": "*"
          },
          {
            "type": "STRING",
            "value": "@"
          },
          {
            "type": "STRING",
            "value": "?"
          },
          {
            "type": "STRING",
            "value": "-"
          },
          {
            "type": "STRING",
            "value": "$"
          },
          {
            "type": "STRING",
            "value": "0"
          },
          {
            "type": "STRING",
            "value": "_"
          }
        ]
      },
      "named": true,
      "value": "special_variable_name"
    },
    "word": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "PATTERN",
                "value": "[^#''\"<>{}\\[\\]()`$|&;\\\\\\s-]"
              },
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "STRING",
                    "value": "\\"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[^\\s]"
                  }
                ]
              }
            ]
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "PATTERN",
                  "value": "[^''\"<>{}\\[\\]()`$|&;\\\\\\s]"
                },
                {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "STRING",
                      "value": "\\"
                    },
                    {
                      "type": "PATTERN",
                      "value": "[^\\s]"
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
    },
    "test_operator": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": 1,
        "content": {
          "type": "SEQ",
          "members": [
            {
              "type": "STRING",
              "value": "-"
            },
            {
              "type": "PATTERN",
              "value": "[a-zA-Z]+"
            }
          ]
        }
      }
    },
    "_terminator": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": ";"
        },
        {
          "type": "STRING",
          "value": ";;"
        },
        {
          "type": "STRING",
          "value": "\n"
        },
        {
          "type": "STRING",
          "value": "&"
        }
      ]
    }
  },
  "extras": [
    {
      "type": "SYMBOL",
      "name": "comment"
    },
    {
      "type": "PATTERN",
      "value": "\\s"
    },
    {
      "type": "PATTERN",
      "value": "\\\\\\r?\\n"
    },
    {
      "type": "PATTERN",
      "value": "\\\\( |\\t|\\v|\\f)"
    }
  ],
  "conflicts": [],
  "precedences": [],
  "externals": [
    {
      "type": "SYMBOL",
      "name": "heredoc_start"
    },
    {
      "type": "SYMBOL",
      "name": "_simple_heredoc_body"
    },
    {
      "type": "SYMBOL",
      "name": "_heredoc_body_beginning"
    },
    {
      "type": "SYMBOL",
      "name": "_heredoc_body_middle"
    },
    {
      "type": "SYMBOL",
      "name": "_heredoc_body_end"
    },
    {
      "type": "SYMBOL",
      "name": "file_descriptor"
    },
    {
      "type": "SYMBOL",
      "name": "_empty_value"
    },
    {
      "type": "SYMBOL",
      "name": "_concat"
    },
    {
      "type": "SYMBOL",
      "name": "variable_name"
    },
    {
      "type": "SYMBOL",
      "name": "regex"
    },
    {
      "type": "STRING",
      "value": "}"
    },
    {
      "type": "STRING",
      "value": "]"
    },
    {
      "type": "STRING",
      "value": "<<"
    },
    {
      "type": "STRING",
      "value": "<<-"
    },
    {
      "type": "STRING",
      "value": "\n"
    },
    {
      "type": "SYMBOL",
      "name": "_flag_start"
    },
    {
      "type": "SYMBOL",
      "name": "flag_argument"
    }
  ],
  "inline": [
    "_statement",
    "_terminator",
    "_literal",
    "_statements2",
    "_primary_expression",
    "_simple_variable_name",
    "_special_variable_name"
  ],
  "supertypes": [
    "_statement",
    "_expression",
    "_primary_expression"
  ]
}

'
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandFromManpage: manpage for: anInfoObject [

	| json |
	json := Json readFrom: manpage readStream.
	^ SBBashCommand new
		commandString: anInfoObject mainCommand;
		commandName: (json at: #name);
		options: (json at: #options);
		synopsis: (json at: #synopsis);
		description: (json at: #description);
		terminal: anInfoObject terminal;
		subcommands: (json at: #commands)
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandObjectFor: anInfoObject [

	| command fallbackSubcommands |
	fallbackSubcommands := OrderedCollection new.
	"this could also be a function in the info object"
	command := anInfoObject terminal commands
		detect: [:c |
			(c commandString includesSubstring: anInfoObject mainCommand, ' ') ifTrue: [fallbackSubcommands add: c].
			c commandString = anInfoObject mainCommand]
		ifNone: [ | subcommands |
			SBToggledCode comment: '' active: 0 do: {[subcommands := anInfoObject terminal commands]}.
			subcommands := fallbackSubcommands.
			SBBashCommand new
				commandString: '';
				subcommands: subcommands;
				subcommandStrings: {};
				options: {};
				description: 'Currently not a valid command';
				synopsis: 'Currently not a valid command';
				terminal: anInfoObject terminal].
	anInfoObject commandObject: command
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandsFrom: anInfoObject into: aCollection [

	| perfectFit goodFits |
	goodFits := OrderedCollection new.
	anInfoObject commandObject: (SBBashCommand new
		commandString: '';
		subcommands: anInfoObject terminal commands;
		subcommandStrings: {};
		options: {};
		description: '';
		synopsis: '';
		terminal: anInfoObject terminal).
	anInfoObject terminal commands do: [:cmd |
		(cmd commandString asLowercase includesSubstring: anInfoObject searchString asLowercase)
			ifTrue: [
				cmd commandString = anInfoObject searchString
					ifTrue: [perfectFit := self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor]
					ifFalse: [goodFits add: (self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor)]]
			ifFalse: [(cmd commandName includesSubstring: anInfoObject searchString) ifTrue: [aCollection add: (self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor)]]].
	aCollection addAllFirst: goodFits.
	perfectFit ifNotNil: [aCollection addFirst: perfectFit]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertFileNameCompletionsFrom: anInfoObject into: aCollection [

	
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	subcommands do: [:subcmd |
		collection add: (SBBashInsertSuggestionItem new
			selector: subcmd commandName;
			morphs: {
					(self blockFor: #word)
						contents: subcmd commandString;
						yourself}
				editor: anInfoObject sandblockEditor;
			key: subcmd commandString)]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSuggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject ifNil: [^ {}].
	anInfoObject commandObject options do: [:option | | morphs flagInfo |
		"TODO: new from json"
		flagInfo := SBBashFlagInformation new
			description: (option at: #description);
			flags: (option at: #flags);
			arguments: ((option at: #arguments) ifNil: [{}]);
			optionals: ((option at: #optionals) ifNil: [{}]).
		
		"TODO: folgenden Blob in Methode auslagern?"
		flagInfo arguments
			ifEmpty: [
				morphs := {
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						yourself}]
			ifNotEmpty: [
				morphs := {
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						yourself.
					(SBBashInput blockFor: #word) in: [:b |
						b lastDeepChild lastSubmorph placeholderText: flagInfo arguments first.
						b]}].
		collection add: (SBBashInsertSuggestionItem new
			selector: flagInfo description;
			morphs: morphs editor: anInfoObject sandblockEditor;
			key: flagInfo firstFlag).
		"with optionals"
		flagInfo optionals notEmpty ifTrue: [
			morphs := flagInfo optionals collect: [:opt |
				(SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
						b lastDeepChild lastSubmorph placeholderText: opt.
						b]);
					yourself].
			collection add: (SBBashInsertSuggestionItem new
				morphs: morphs editor: anInfoObject sandblockEditor;
				key: flagInfo firstFlag)]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadOnlyNextSubcommandsFor: anInfoObject [

	| subcommands |
	anInfoObject commandObject ifNil: [^ {}].
	subcommands := anInfoObject commandObject subcommands collect: [:cmdObj | | from upto |
		from := anInfoObject mainCommand size + 2.
		upto := (cmdObj commandString findString: ' ' startingAt: from) - 1.
		upto < 0 ifTrue: [upto := cmdObj commandString size].
		cmdObj commandString size >= from ifTrue: [ | newCommandObject |
			newCommandObject := cmdObj shallowCopy.
			newCommandObject commandString: (cmdObj commandString from: from to: upto).
			newCommandObject]].
	subcommands := subcommands select: [:cmdObj | cmdObj notNil].
	"subcommands := (subcommands
		collect: [:cmdObj | cmdObj commandString -> true]
		into: OrderedDictionary new) keys.
	1 halt."
	^ subcommands
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	subcommands do: [:subcmd |
		(subcmd commandName asLowercase includesSubstring: anInfoObject searchString asLowercase) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: subcmd commandName;
				blocks: {
						(self blockFor: #word)
							contents: subcmd commandString;
							yourself}
					in: anInfoObject sandblockEditor;
				option: subcmd commandString;
				key: subcmd commandString)]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadSuggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject ifNil: [^ {}].
	anInfoObject commandObject options do: [:option | | morphs flagInfo |
		flagInfo := SBBashFlagInformation new
			description: (option at: #description);
			flags: (option at: #flags);
			arguments: (option at: #arguments);
			optionals: (option at: #optionals).
			
		flagInfo arguments
			ifEmpty: [
				morphs := {
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						yourself}]
			ifNotEmpty: [
				morphs := {
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						yourself.
					(SBBashInput blockFor: #word) in: [:b |
						b lastDeepChild lastSubmorph placeholderText: flagInfo arguments first.
						b]}].
		((flagInfo flagsJoined asLowercase includesSubstring: anInfoObject searchString asLowercase) or: (flagInfo description asLowercase includesSubstring: anInfoObject searchString asLowercase)) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: flagInfo description;
				blocks: morphs in: anInfoObject sandblockEditor;
				option: flagInfo firstFlag;
				terminalCommand: anInfoObject mainCommand).
			"with optionals"
			flagInfo optionals notEmpty ifTrue: [
				morphs := flagInfo optionals collect: [:opt |
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
							b lastDeepChild lastSubmorph placeholderText: opt.
							b]);
						yourself].
				collection add: (SBBashTSBlockSuggestion new
					blocks: morphs in: anInfoObject sandblockEditor;
					option: flagInfo firstFlag;
					terminalCommand: anInfoObject mainCommand;
					key: flagInfo firstFlag, 'optional')]]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> showInsertHints [

	^ false
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestAlwaysFor: aBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFor2: aBlock [

	(aBlock type = #word and: [aBlock parentSandblock type = #command]) ifTrue: [
		^ {
			SBTSBlockSuggestion new
				blocks: {(self parseToplevel: 'command ', 'FILL') childSandblocks first childSandblocks second}
				in: aBlock sandblockEditor}].
	^ #()
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFor: aBlock [

	| suggestions info terminal searchString onlyShowFlags |
	suggestions := OrderedCollection new.
	(aBlock type ~= #word and: [aBlock type ~= #flag]) ifTrue: [^ suggestions].
	
	(aBlock sourceString startsWith: '-')
		ifTrue: [
			onlyShowFlags := true.
			(aBlock sourceString startsWith: '--')
				ifTrue: [searchString := aBlock sourceString from: (3 min: aBlock sourceString size)]
				ifFalse: [searchString := aBlock sourceString from: (2 min: aBlock sourceString size)]]
		ifFalse: [
			onlyShowFlags := false.
			searchString := aBlock sourceString].
	"Könnte in eine Methode SBBashCommandInformation >> newFromBlock: aBlock"
	terminal := aBlock containingArtefact.
	info := SBBashCommandInformation new
		fullCommand: aBlock parentSandblock sourceString;
		searchString: searchString;
		terminal: terminal;
		sandblockEditor: aBlock sandblockEditor.
	
	aBlock parentSandblock type = #'command_name' ifTrue: [
		"reduce lag by only searching commands beyond a certain length"
		info searchString size >= 3 ifTrue: [self loadCommandsFrom: info into: suggestions].
		^ self deduplicateBashSuggestions: suggestions].
	
	self loadCommandObjectFor: info.
	onlyShowFlags ifFalse: [self loadSubcommandsFrom: info into: suggestions].
	self loadSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description.
		terminal debugOutput: info mainCommand].
	^ self deduplicateBashSuggestions: suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsForInsert: aCommand [

	| suggestions terminal info container |
	suggestions := OrderedCollection new.
	((aCommand element isTSChoice and: [aCommand element alternatives noneSatisfy: [:alt | alt type = #'_primary_expression']]) and: [aCommand element type ~= #'flag_argument']) ifTrue: [^ suggestions].
	container := aCommand container.
	terminal := container containingArtefact.
	
	aCommand element type = #'flag_argument' ifTrue: [container := container parentSandblock].
	
	info := SBBashCommandInformation new
		fullCommand: container sourceString;
		terminal: terminal;
		sandblockEditor: container sandblockEditor.
	
	self loadCommandObjectFor: info.
	self loadInsertFileNameCompletionsFrom: info into: suggestions.
	info fullCommand = '' ifFalse: [self loadInsertSubcommandsFrom: info into: suggestions].
	self loadInsertSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description].
	
	^ self deduplicateBashSuggestions: suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> transitionPairs [

	^ {#command -> #'function_definition'}
]
