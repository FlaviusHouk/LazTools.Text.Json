using GLib;

namespace LazTools.Json
{
	public abstract class JsonTypeSerializer<T> : Object,
					              IJsonTypeSerializer
	{
		public bool CanHandleType(Type type)
		{
			Type currentType = typeof(T);
			return type.is_a(currentType);
		}

		public abstract void SerializeValue(Value value, Type valueType, JsonWriter writer);

		public abstract void Serialize(T obj, JsonWriter writer);
	}
}
