using Gee;
using GLib;

namespace LazTools.Json
{
	public class JsonSerializationContext : Object
	{
		private Gee.List<IJsonTypeSerializer> _serializers;

		public JsonSerializationContext()
		{
			_serializers = new ArrayList<IJsonTypeSerializer>();
		}

		public void RegisterSerializer(IJsonTypeSerializer serializer)
		{
			_serializers.add(serializer);
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
	}
}
