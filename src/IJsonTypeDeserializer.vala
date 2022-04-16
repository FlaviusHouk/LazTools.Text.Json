using GLib;

namespace LazTools.Text.Json
{
	public interface IJsonTypeDeserializer : Object
	{
		public abstract bool CanHandleType(Type t);	
	}
}
