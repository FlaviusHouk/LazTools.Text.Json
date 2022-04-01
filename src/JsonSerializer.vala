using GLib;

namespace LazTools.Json
{
	public class JsonSerializer
	{
		private JsonSerializer()
		{}

		public static string SerializeToString<T>(T obj,
							  JsonSerializationContext? ctx = null) throws JsonError, Error
		{
			MemoryOutputStream output = 
				new MemoryOutputStream(null, realloc, free);

			SerializeToStream<T>(obj, output, ctx);
			output.close();

			uint8[] data = output.steal_data();
			data.length = (int)output.get_data_size();

			return (string)data;	
		}

		public static void SerializeToStream<T>(T obj,
						        OutputStream stream,
							JsonSerializationContext? ctx = null) throws JsonError, Error
		{
			JsonWriter writer = new JsonWriter(stream);
			WriteUnknown<T>(obj, writer, ctx);
		}

		private static void SerializeObject(Object obj,
						    Type type,
						    JsonWriter writer,
						    JsonSerializationContext? ctx = null) throws JsonError, Error
		{
			var typeClass = (ObjectClass)type.class_ref();
			ParamSpec[] properties =
				typeClass.list_properties();
			
			writer.StartObject();
			foreach(var prop in properties)
			{
				Value propValue = Value(prop.value_type);
				writer.WriteProperty(prop.name);
				obj.get_property(prop.name, ref propValue);
				SerializeValue(propValue, prop.value_type, writer, ctx);
				
			}
			writer.EndObject();
		}
		

		private static void SerializeValue(Value value,
						   Type valueType,
						   JsonWriter writer,
						   JsonSerializationContext? ctx = null) throws JsonError, Error
		{
			if(valueType.is_a(Type.INT))
			{
				WriteUnknown<int>(value.get_int(), writer, ctx);
			}
			/*else if (valueType.is_a(Type.DOUBLE))
			{
				WriteUnknown<double>(value.get_double(), writer, ctx);
			}*/
			else if (valueType.is_a(Type.BOOLEAN))
			{
				WriteUnknown<bool>(value.get_boolean(), writer, ctx);
			}
			else if(valueType.is_a(Type.STRING))
			{
				WriteUnknown<string>(value.get_string(), writer, ctx);
			}
			else if(valueType.is_a(Type.OBJECT))
			{
				SerializeObject(value.get_object(), valueType, writer, ctx);
			}
			else if(valueType.is_a(Type.BOXED))
			{
				if(ctx == null)
				{
					throw new JsonError.NO_SERIALIZER_FOUND(@"Cannot serialize type (valueType.name()). No context.");
				}

				IJsonTypeSerializer serializer = 
					ctx.LookupSerializerForType(valueType);

				serializer.SerializeValue(value, valueType, writer);
			}
			
		}

		private static void WriteUnknown<T>(T obj,
						    JsonWriter writer,
						    JsonSerializationContext? ctx = null) throws JsonError, Error
		{
			Type type = typeof(T);
			
			if(type.is_object())
			{
				Object object = (Object)obj;
				SerializeObject(object, type, writer, ctx);
			}
			else if (type.is_a (Type.INT))
			{
				int i = (int)obj;
				writer.WriteInt32(i);
			}
			else if (type.is_a (Type.BOOLEAN))
			{
				bool b = (bool)obj;
				writer.WriteBoolean(b);
			}
		}
	}
}
