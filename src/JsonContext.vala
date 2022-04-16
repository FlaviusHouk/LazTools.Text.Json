using Gee;
using GLib;

namespace LazTools.Text.Json
{
	public class JsonContext : Object
	{
		private Gee.List<IJsonTypeSerializer> _serializers;
		private Gee.List<IJsonTypeDeserializer> _deserializers;

		public bool HandleEnumAsString { get; set; }

		public JsonContext()
		{
			_serializers = new ArrayList<IJsonTypeSerializer>();
			_deserializers = new ArrayList<IJsonTypeDeserializer>();
		}

		public void RegisterSerializer(IJsonTypeSerializer serializer)
		{
			_serializers.add(serializer);
		}

		public void RegisterDeserializer(IJsonTypeDeserializer deserializer)
		{
			_deserializers.add(deserializer);
		}

		public IJsonTypeSerializer LookupSerializerForType(Type t) throws JsonError
		{
			for(int i = 0; i < _serializers.size; i++)
			{
				IJsonTypeSerializer serializer = _serializers[i];
				
				if(serializer.CanHandleType(t))
					return serializer;
			}

			throw new JsonError.NO_SERIALIZER_FOUND(@"Cannot find serializer for type $(t.name())");
		}

		public IJsonTypeDeserializer LookupDeserializerForType(Type t) throws JsonError
		{
			for(int i = 0; i < _deserializers.size; i++)
			{
				IJsonTypeDeserializer deserializer = _deserializers[i];

				if(deserializer.CanHandleType(t))
					return deserializer;
			}

			throw new JsonError.NO_DESERIALIZER_FOUND(@"Cannot find deserializer for type $(t.name())");
		}
	}
}
