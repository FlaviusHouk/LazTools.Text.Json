using GLib;

namespace LazTools
{
	public delegate T Action<T>();

	public class Lazy<T>
	{
		private bool _isValueCreated;
		private T _value;
		private Action<T> _factory;
		private Object? _locker;

		public T Value
		{
			get
			{
				if(!_isValueCreated)
				{

					if(_locker != null)
					{
						lock(_locker)
						{
							_value = _factory();
						}
					}
					else
					{
						_value = _factory();
					}
				}

				return _value;
			}
		}

		public Lazy(Action<T> factory, bool isThreadSafe = true)
		{
			_factory = () => { return factory(); };
			_isValueCreated = false;
			_locker = null;
			
			if(isThreadSafe)
			{
				_locker = new Object();
			}
		}
	}
}
