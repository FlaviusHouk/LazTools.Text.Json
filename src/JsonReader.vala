using Gee;
using GLib;

namespace LazTools.Text.Json
{
	internal class JsonReaderState : Object
	{
		public JsonTokenType CurrentToken { get; set; }
		public JsonReaderStateEnum State { get; set; }
		public int InternalState { get; set; }
	}

	public class JsonReader : Object
	{
		private DataInputStream _input;

		private Deque<JsonReaderState?> _stateStack;

		private string? _currentLine;
		private int _position;
		private int _bufferLength;

		public JsonTokenType Token
		{
			get
			{
				JsonReaderState? currState = GetCurrentState();
				return currState.CurrentToken;
			}
		}

		public JsonReader(InputStream input)
		{
			if(input is DataInputStream)
				_input = (DataInputStream)input;
			else
				_input = new DataInputStream(input);

			_position = 0;
			_bufferLength = 0;
			_currentLine = null;
			
			_stateStack = new ArrayQueue<JsonReaderState?>();
			JsonReaderState initialState = new JsonReaderState()
			{
				CurrentToken = JsonTokenType.DocumentStart,
				State = JsonReaderStateEnum.DocumentStart,
				InternalState = 0
			};
			_stateStack.offer_tail(initialState);
		}

		public bool Proceed()
		{
			_position += _bufferLength;
			_bufferLength = 0;

			FillBuffer();

			PrepareNextValue();

			JsonReaderState state = GetCurrentState();
			
			return !(state.State == JsonReaderStateEnum.DocumentStart && state.InternalState == -1);
		}

		public int? ReadInt32()
		{
			if(Token == JsonTokenType.Null)
				return null;
			else if(Token != JsonTokenType.Number)
				throw new JsonError.INVALID_VALUE("Cannot read int32 number.");

			string number = _currentLine.substring(_position, _bufferLength);
			return int.parse(number);
		}

		public string ReadPropertyName()
		{
			if(Token != JsonTokenType.Property)
				throw new JsonError.INVALID_VALUE("Cannot read property name.");

			return _currentLine.substring(_position, _bufferLength).replace("\"", "");
		}

		public string? ReadString()
		{
			if(Token == JsonTokenType.Null)
				return null;
			else if (Token != JsonTokenType.String)
				throw new JsonError.INVALID_VALUE("Cannot read string value");

			return _currentLine.substring(_position, _bufferLength);
		}

		public bool? ReadBoolean()
		{
			if(Token == JsonTokenType.Null)
				return null;
			else if(Token != JsonTokenType.Boolean)
				throw new JsonError.INVALID_VALUE("Cannot read bool value.");

			string boolValue = _currentLine.substring(_position, _bufferLength);
			return bool.parse(boolValue);
		}

		public float? ReadFloat()
		{
			if(Token == JsonTokenType.Null)
				return null;
			else if(Token != JsonTokenType.Number)
				throw new JsonError.INVALID_VALUE("Cannot read float number.");

			string number = _currentLine.substring(_position, _bufferLength);
			return float.parse(number);
		}

		public double? ReadDouble()
		{
			if(Token == JsonTokenType.Null)
				return null;
			else if(Token != JsonTokenType.Number)
				throw new JsonError.INVALID_VALUE("Cannot read double number.");

			string number = _currentLine.substring(_position, _bufferLength);
			return double.parse(number);
		}

		private void FillBuffer()
		{
			JsonReaderState state = GetCurrentState();

			if(_currentLine != null && _currentLine.length > _position || state.State == JsonReaderStateEnum.DocumentStart && state.InternalState == -1)
				return;

			_currentLine = _input.read_line();

			if(_currentLine == null)
			{
				if(state.State != JsonReaderStateEnum.DocumentStart)
					throw new JsonError.INVALID_JSON("Unexpected end.");

				state.InternalState = -1;
			}

			_position = 0;
		}

		private void PrepareNextValue()
		{
			JsonReaderState currentState = GetCurrentState();

			if(currentState.State == JsonReaderStateEnum.Object)
				ProcessObject();
			else if(currentState.State == JsonReaderStateEnum.Array)
				ProcessArray();
			else if(currentState.State == JsonReaderStateEnum.LiteralValue)
				ProcessLiteral();
			else if(currentState.State == JsonReaderStateEnum.StringValue)
				ProcessString();
			else if(currentState.State == JsonReaderStateEnum.NumberValue)
				ProcessNumber();
			else
				EnterValue();
		}

		private JsonReaderState? GetCurrentState()
		{
			return _stateStack.peek_tail();
		}

		private void EnterValue()
		{
			unichar c = _currentLine.get_char(_position + _bufferLength);
			switch(c)
			{
				case '[':
					JsonReaderState arrayState = new JsonReaderState()
					{
						CurrentToken = JsonTokenType.ArrayStart,
						State = JsonReaderStateEnum.Array,
						InternalState = 1
					};

					_stateStack.offer_tail(arrayState);
					_position++;

					break;
				case '{':
					JsonReaderState objectState = new JsonReaderState()
					{
						CurrentToken = JsonTokenType.ObjectStart,
						State = JsonReaderStateEnum.Object,
						InternalState = 1
					};

					_stateStack.offer_tail(objectState);
					_position++;
					break;
				default:
					if(c == 't' || c == 'f' || c == 'n')
					{
						JsonReaderState literalState = new JsonReaderState()
						{
							State = JsonReaderStateEnum.LiteralValue,
							InternalState = 1
						};

						_stateStack.offer_tail(literalState);

						ProcessLiteral();
					}
					else if(c == '\"')
					{
						JsonReaderState stringState = new JsonReaderState()
						{
							CurrentToken = JsonTokenType.String,
							State = JsonReaderStateEnum.StringValue,
							InternalState = 1
						};

						_stateStack.offer_tail(stringState);

						ProcessString();
					}
					else if(c.isdigit() || c == '-')
					{
						JsonReaderState numberState = new JsonReaderState()
						{
							CurrentToken = JsonTokenType.Number,
							State = JsonReaderStateEnum.NumberValue,
							InternalState = c == '-' ? 1 : 2
						};

						_stateStack.offer_tail(numberState);

						ProcessNumber();
					}
					else if(c.isspace())
					{
						_position++;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected character.");
					}

					break;
			}
		}

		private void ProcessNumber()
		{
			JsonReaderState currentState = GetCurrentState();
			
			const int Sign = 1;
			const int WholePart = 2;
			const int Separator = 3;
			const int DecimalPart = 4;

			if(currentState.InternalState == -1)
			{
				_stateStack.poll_tail();
				PrepareNextValue();
				return;
			}

			while(currentState.InternalState != -1)
			{
				unichar c = _currentLine.get_char(_position + _bufferLength);
				
				if(currentState.InternalState == Sign)
				{
					if(c == '-')
					{
						currentState.InternalState = WholePart;
						_bufferLength++;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unknown character.");
					}
				}
				else if(currentState.InternalState == WholePart)
				{
					if(c.isdigit())
					{
						_bufferLength++;
					}
					else if(c == '.')
					{
						currentState.InternalState = Separator;
						_bufferLength++;
					}
					else
					{
						currentState.InternalState = -1;
					}
				}
				else if(currentState.InternalState == Separator)
				{
					if(c.isdigit())
					{
						_bufferLength++;
						currentState.InternalState = DecimalPart;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Invalid number");
					}
				}
				else if(currentState.InternalState == DecimalPart)
				{
					if(c.isdigit())
					{
						_bufferLength++;
					}
					else
					{
						currentState.InternalState = -1;
					}
				}
			}
		}

		private void ProcessString()
		{
			JsonReaderState currentState = GetCurrentState();

			const int StartString = 1;
			const int Content = 2;
			
			if(currentState.InternalState == -1)
			{
				_stateStack.poll_tail();
				PrepareNextValue();
				return;
			}

			while(currentState.InternalState != -1)
			{
				unichar c = _currentLine.get_char(_position + _bufferLength);

				if(currentState.InternalState == StartString)
				{
					if(c == '\"')
					{
						currentState.InternalState = Content;
						_bufferLength++;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Invalid string");
					}
				}
				else if(currentState.InternalState == Content)
				{
					if(c == '\"')
					{
						currentState.InternalState = -1;
					}

					_bufferLength++;
				}
			}
		}

		private void ProcessLiteral()
		{
			JsonReaderState currentState = GetCurrentState();

			if(currentState.InternalState == -1)
			{
				_stateStack.poll_tail();
				PrepareNextValue();
				return;
			}

			unichar c = _currentLine.get_char(_position + _bufferLength);
			if(c == 't')
			{
				_bufferLength = 4;
				string trueString = _currentLine.substring(_position, _bufferLength);
				
				if(trueString != "true")
					throw new JsonError.INVALID_JSON("Invalid literal");

				currentState.CurrentToken = JsonTokenType.Boolean;
			}
			else if(c == 'n')
			{
				_bufferLength = 4;
				string trueString = _currentLine.substring(_position, _bufferLength);
				
				if(trueString != "null")
					throw new JsonError.INVALID_JSON("Invalid literal");

				currentState.CurrentToken = JsonTokenType.Null;
			}
			else if(c == 'f')
			{
				_bufferLength = 5;
				string trueString = _currentLine.substring(_position, _bufferLength);
				
				if(trueString != "false")
					throw new JsonError.INVALID_JSON("Invalid literal");

				currentState.CurrentToken = JsonTokenType.Boolean;
			}
			else
			{
				throw new JsonError.INVALID_JSON("Unknown literal");
			}

			currentState.InternalState = -1;
		}

		private void ProcessArray()
		{
			JsonReaderState currentState = GetCurrentState();

			const int LaterValue = 2;

			if(currentState.InternalState == -1)
			{
				_stateStack.poll_tail();
				PrepareNextValue();
				return;
			}

			unichar c = _currentLine.get_char(_position + _bufferLength);

			if(c == ']')
			{
				if(c == ',')
					throw new JsonError.INVALID_JSON("Expected value");

				_position++;
				currentState.InternalState = -1;
			}
			else if(currentState.InternalState == LaterValue)
			{
				if(c != ',')
					throw new JsonError.INVALID_JSON("Missing comma");

				_position++;
				EnterValue();
			}
			else
			{
				currentState.InternalState = LaterValue;
				EnterValue();
			}
		}

		private void ProcessObject()
		{
			JsonReaderState currentState = GetCurrentState();

			const int OpenProperty = 3;
			const int Property = 4;
			const int CloseProperty = 5;
			const int ValueSeparator = 6;
			const int AfterValue = 7;

			if(currentState.InternalState == -1)
			{
				_stateStack.poll_tail();
				PrepareNextValue();
				return;
			}

			while(currentState.InternalState != -1)
			{
				unichar c = _currentLine.get_char(_position + _bufferLength);

				if(currentState.InternalState == 1)
				{
					if(c == '\"')
					{
						currentState.InternalState = OpenProperty;
						_position++;
					}
					else if(c == '}')
					{
						currentState.InternalState = -1;
						_position++;
						currentState.CurrentToken = JsonTokenType.ObjectEnd;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected char.");
					}
				}
				else if(currentState.InternalState == OpenProperty)
				{
					if(c.isalpha())
					{
						_bufferLength++;
						currentState.InternalState = Property;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected char.");
					}
				}
				else if(currentState.InternalState == Property)
				{
					if(c.isalnum())
					{
						_bufferLength++;
					}
					else if(c == '\"')
					{
						_bufferLength++;
						currentState.CurrentToken = JsonTokenType.Property;
						currentState.InternalState = CloseProperty;
						return;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected char.");
					}
				}
				else if(currentState.InternalState == CloseProperty)
				{
					if(c.isspace())
					{
						_position++;
					}
					else if(c == ':')
					{
						_position++;
						currentState.InternalState = ValueSeparator;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected char.");
					}
				}
				else if(currentState.InternalState == ValueSeparator)
				{
					if(c.isspace())
					{
						_position++;
					}
					else
					{
						EnterValue();
						currentState.InternalState = AfterValue;
						return;
					}
				}
				else if(currentState.InternalState == AfterValue)
				{
					if(c == '}')
					{
						currentState.InternalState = -1;
						currentState.CurrentToken = JsonTokenType.ObjectEnd;
						_position++;
					}
					else if(c == ',')
					{
						currentState.InternalState = 1;
						_position++;
					}
					else
					{
						throw new JsonError.INVALID_JSON("Unexpected char.");
					}
				}
			}
		}
	} 
}
