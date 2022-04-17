using GLib;

namespace LazTools.Text.Json
{
	public class ArraySerializer<T> : Object, IJsonTypeSerializer
	{
		public bool CanHandleType(Type type)
		{
			Type arrayType = typeof(Array<T>);
			return type.is_a(arrayType);
		}

		public void SerializeValue(Value value, Type valueType, JsonWriter writer, JsonContext ctx)
		{
			Array<T>? arr = (Array<T>?)value.peek_pointer();
			if(arr == null)
			{
				writer.WriteNull();
				return;
			}

			writer.StartArray();
			for(int i = 0; i < arr.length; i++)
			{
				JsonSerializer.SerializeToWriter<T>(arr.index(i), writer, ctx);
			}
			writer.EndArray();
		}
	}
}
