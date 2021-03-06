# Learnability Term Paper

Do neural networks make human like errors in acquiring morphological
inflection patterns? This experiment aims to answer that question by
training an LSTM model to predict English past tense verb forms from
their present tense stems and comparing the errors generated to
those observed in real children. English speaking children have been
notably observed to overregularize irregular verbs when forming the
past tense, yet have not been observed producing doubly marked forms.

The results generated by this model demonstrate the marked similarity
between human and neural network language aquisition in three ways.
First, despite the fact that this is a simple one-shot LSTM model
lacking sophisticated hyperparameer tuning, it managed to achieve a
word error rate of only 11.13, suggesting that it generalizes over 
the past tense with a high degree of accuracy. Second, it can be
clearly seen within the errata that overregularized past tense forms
are commonly associated with irregular verbs. Finally, though the
corpus used was relatively small, the model generated no doubly
marked forms.

Examples of overregularized forms can be seen in the following table.


| Present        | Past          | Overregularized |
| ------------- | ------------- | --------------- |
| swing         | swung         | swinged         |
| grind         | ground        | grinded         |
| ingrow        | ingrew        | ingrowed        |

