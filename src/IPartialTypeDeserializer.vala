using GLib;

namespace LazTools.Text.Json
{
	public interface IPartialTypeDeserializer : Object, IJsonTypeDeserializer
	{
		public abstract Value CreateInstance();

		public abstract Type GetPropertyType(string propertyName);

		public abstract void SetProperty(Value instance, string propertyName, Value value);
	}
}
