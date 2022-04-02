using Gee;
using GLib;

namespace LazTools.Text.Json
{
	internal struct JsonWriterStateTransition
	{
		public JsonWriterState Source;
		public JsonWriterState Destination;
	}

	public class JsonWriter
	{
		private static JsonWriterStateTransition[] _transitionsWithCommas = 
			new JsonWriterStateTransition[]
		{
			JsonWriterStateTransition()
			{
				Source = JsonWriterState.Primitive,
				Destination = JsonWriterState.Primitive
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.Primitive,
				Destination = JsonWriterState.StartObject
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.Primitive,
				Destination = JsonWriterState.StartArray
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndObject,
				Destination = JsonWriterState.Primitive
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndObject,
				Destination = JsonWriterState.Property
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndObject,
				Destination = JsonWriterState.StartObject
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndObject,
				Destination = JsonWriterState.StartArray
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndArray,
				Destination = JsonWriterState.Primitive
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndArray,
				Destination = JsonWriterState.StartObject
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.EndArray,
				Destination = JsonWriterState.StartArray
			},

			JsonWriterStateTransition()
			{
				Source = JsonWriterState.Primitive,
				Destination = JsonWriterState.Property
			},
		};


		private OutputStream _stream;
		private JsonWriterState _state;

		public JsonWriter(OutputStream stream)
		{
			_stream = stream;
			_state = JsonWriterState.Start;
		}

		public void StartObject() throws Error
		{
			GoToState(JsonWriterState.StartObject);

			size_t bytesWritten;
			_stream.printf(out bytesWritten, null, "%s", "{");
		}

		public void EndObject() throws Error
		{
			GoToState(JsonWriterState.EndObject);

			size_t bytesWritten;
			_stream.printf(out bytesWritten, null, "%s", "}");
		}
		
		public void StartArray() throws Error
		{
			GoToState(JsonWriterState.StartArray);

			size_t bytesWritten;
			_stream.printf(out bytesWritten, null, "%s", "[");
		}

		public void EndArray() throws Error
		{
			GoToState(JsonWriterState.EndArray);

			size_t bytesWritten;
			_stream.printf(out bytesWritten, null, "%s", "]");
		}

		public void WriteProperty(string propName) throws Error
		{
			GoToState(JsonWriterState.Property);

			size_t bytesWritten;
			string format = "\"%s\":";

			_stream.printf(out bytesWritten, null, format, propName);
		}

		public void WriteInt8(int8 number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%d";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteInt16(int16 number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%d";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteInt32(int32 number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%d";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteInt64(int64 number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%d";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteFloat(float number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%f";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteDouble(double number) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "%f";

			_stream.printf(out bytesWritten, null, format, number);
		}

		public void WriteNull() throws Error
		{
			WriteString("null");
		}

		public void WriteBoolean(bool value) throws Error
		{
			WriteString(value.to_string());
		}

		public void WriteString(string str) throws Error
		{
			GoToState(JsonWriterState.Primitive);

			size_t bytesWritten;
			string format = "\"%s\"";

			_stream.printf(out bytesWritten, null, format, str);
		}

		private void GoToState(JsonWriterState newState) throws Error
		{
			foreach(var transition in _transitionsWithCommas)
			{
				if(transition.Source == _state && transition.Destination == newState)
				{
					size_t bytesWritten;
					string format = "%s";

					_stream.printf(out bytesWritten, null, format, ",");

					break;
				}
			}

			_state = newState;
		}
	}
}
