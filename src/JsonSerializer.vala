using GLib;

namespace LazTools.Text.Json
{
	public class JsonSerializer
	{
		private static Lazy<JsonSerializationContext> _defaultContextCreator =
			new Lazy<JsonSerializationContext>(CreateDefaultContext);

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
			SerializeToWriter<T>(obj, writer, ctx);
		}

		public static void SerializeToWriter<T>(T obj,
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
			else if (type.is_a(Type.DOUBLE))
			{
				double? d = (double?)obj;

				if(d == null)
					writer.WriteNull();
				else
					writer.WriteDouble(d);
			}
			else if(type.is_a(Type.FLOAT))
			{
				float? f = (float?)obj;
				
				if(f == null)
					writer.WriteNull();
				else
					writer.WriteFloat(f);
			}
			else if(type.is_a(Type.STRING))
			{
				string? s = (string?)obj;

				if(s == null)
					writer.WriteNull();
				else
					writer.WriteString(s);
			}
			else if(type.is_a(Type.BOXED))
			{
				if(ctx == null)
				{
					throw new JsonError.NO_SERIALIZER_FOUND(@"Cannot serialize type (valueType.name()). No context.");
				}

				IJsonTypeSerializer serializer = 
					ctx.LookupSerializerForType(type);

				JsonTypeSerializer<T> typeSerializer =
					(JsonTypeSerializer<T>)serializer;

				typeSerializer.Serialize(obj, writer, ctx);
			}
		}

		public static T? DeserializeFromString<T>(string json)
		{
			MemoryInputStream input =
				new MemoryInputStream.from_data(json.data);

			T obj = DeserializeFromStream<T>(input);

			input.close();

			return obj;
		}

		public static T? DeserializeFromStream<T>(InputStream stream)
		{
			JsonReader reader = new JsonReader(stream);
			return DeserializeFromReader<T>(reader);
		}

		public static T? DeserializeFromReader<T>(JsonReader reader)
		{
			Type t = typeof(T);
			Value val = GetValue(reader, t);
			if(t == Type.INT)
			{
				return (T?)val.get_int();
			}
			else if(t.is_a(Type.OBJECT))
			{
				return (T?)val.get_object();
			}
			else
			{
				throw new JsonError.INVALID_JSON("Invalid type");
			}
		}

		public static Value DeserializePrimitive(JsonReader reader, Type t)
		{	
			Value v = Value(t);

			if(!reader.Proceed())
				return v;

			if(t == Type.INT)
			{
				v.set_int(reader.ReadInt32());
			}
			else if(t == Type.STRING)
			{
				v.set_string(reader.ReadString());
			}
			else if(t == Type.BOOLEAN)
			{
				v.set_boolean(reader.ReadBoolean());
			}
			else if(t == Type.FLOAT)
			{
				v.set_float(reader.ReadFloat());
			}
			else if(t == Type.DOUBLE)
			{
				v.set_double(reader.ReadDouble());
			}
			else
			{
				throw new JsonError.INVALID_JSON("Unexpected type.");
			}

			return v;
		}

		public static Object DeserializeObject(JsonReader reader, Type t)
		{
			if(!reader.Proceed() || reader.Token != JsonTokenType.ObjectStart)
				throw new JsonError.INVALID_JSON("Parsing error");

			Object obj = Object.new(t);
			ObjectClass objClass = (ObjectClass)t.class_ref();
	
			while(reader.Proceed() && reader.Token != JsonTokenType.ObjectEnd)
			{
				string propName = reader.ReadPropertyName();

				ParamSpec? prop = objClass.find_property(propName);
				if(prop == null)
					throw new JsonError.INVALID_JSON("Cannot find property of the object");
				
				Value propVal = GetValue(reader, prop.value_type);

				obj.set_property(propName, propVal);
			}

			return obj;
		}

		public static void* DeserializeStruct(JsonReader reader, Type t)
		{
			TypeQuery query;
			t.query(out query);

			void* mem = malloc(query.instance_size);
			//Add context with deseializers
			//deserializer.deserialize(mem);

			return mem;
		}

		private static Value GetValue(JsonReader reader, Type t)
		{
			if(t.is_fundamental())
			{	
				if(t.is_classed())
				{
				}
				else
				{
					//Probably only primitive will be here	
					return DeserializePrimitive(reader, t);
				}
			}
			else if(t.is_a(Type.BOXED))
			{
				//Maybe structs will be here
			}
			else if(t.is_object())
			{
				Value v = Value(t);
				Object obj = DeserializeObject(reader, t);
				v.set_object(obj);
				return v;
			}
			else
			{
				//Maybe enums will be here and something else.
			}

			throw new JsonError.INVALID_JSON("Not impletented.");
		}

		private static JsonSerializationContext CreateDefaultContext()
		{
			JsonSerializationContext ctx = new JsonSerializationContext();

			return ctx;
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
				SerializeToWriter<int>(value.get_int(), writer, ctx);
			}
			else if (valueType.is_a(Type.DOUBLE))
			{
				SerializeToWriter<double?>(value.get_double(), writer, ctx);
			}
			else if (valueType.is_a(Type.FLOAT))
			{
				SerializeToWriter<float?>(value.get_float(), writer, ctx);
			}
			else if (valueType.is_a(Type.BOOLEAN))
			{
				SerializeToWriter<bool>(value.get_boolean(), writer, ctx);
			}
			else if(valueType.is_a(Type.STRING))
			{
				SerializeToWriter<string>(value.get_string(), writer, ctx);
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

				serializer.SerializeValue(value, valueType, writer, ctx);
			}
			
		}	
	}
}
