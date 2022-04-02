using GLib;
using LazTools.Text.Json;

namespace LazTools
{
	public struct Point
	{
		public int X;
		public int Y;
	}

	public class TestClass : Object
	{
		public int X { get; set; }
		public int Y { get; set; }
	}

	public class TestClass2 : Object
	{
		public TestClass Position { get; set; }
		public int Id { get; set; }
		public Point LogicalPosition { get; set; }
	}

	internal class PointJsonSerializer : JsonTypeSerializer<Point?>
	{
		public override void SerializeValue(Value value, Type valueType, JsonWriter writer)
		{
			Serialize((Point?)value.get_boxed(), writer);
		}

		public override void Serialize(Point? obj, JsonWriter writer)
		{
			if(obj == null)
			{
				writer.WriteNull();
				return;
			}

			writer.StartObject();
			writer.WriteProperty("X");
			writer.WriteInt32(obj.X);
			writer.WriteProperty("Y");
			writer.WriteInt32(obj.Y);
			writer.EndObject();
		}
	}

	public class Sample : Object
	{
		public static void DoAction<T>(T obj)
		{
			Type t = typeof(T);
			if(t.is_a(Type.INT))
			{
				int val = (int)obj;
				stdout.printf("%s - %d\n", t.name(), val);
			}
		}

		public static void main(string[] args)
		{
			TestClass2 t2 = new TestClass2();
			Point p = Point()
			{
				X = 125,
				Y = 250
			};

			TestClass t = new TestClass();
			t.X = 1;
			t.Y = 2;

			t2.Id = 1;
			t2.Position = t;
			t2.LogicalPosition = p;

			JsonSerializationContext ctx = new JsonSerializationContext();
			PointJsonSerializer s1 = new PointJsonSerializer();
			ctx.RegisterSerializer(s1);

			string json = JsonSerializer.SerializeToString<TestClass2>(t2, ctx);
			stdout.printf("%s\n", json);
		}
	}
}
