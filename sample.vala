using GLib;
using LazTools.Text.Json;

namespace LazTools
{
	public struct Point
	{
		public int X;
		public int Y;
	}

	public class BIO : Object
	{
		public string Name { get; set; }
		public string LastName { get; set; }
	}

	public class TestClass : Object
	{
		public int X { get; set; }
		public double Y { get; set; }
		public bool TBool { get; set; }
		public string TString { get; set; }
		public BIO TBio { get; set; }
	}

	public class TestClass2 : Object
	{
		public TestClass Position { get; set; }
		public int Id { get; set; }
		public Point LogicalPosition { get; set; }
		public int[] Data { get; set; }
	}

	/*internal class PointJsonSerializer : JsonTypeSerializer<Point?>
	{
		public override void SerializeValue(Value value, Type valueType, JsonWriter writer, JsonSerializationContext ctx)
		{
			Serialize((Point?)value.get_boxed(), writer, ctx);
		}

		public override void Serialize(Point? obj, JsonWriter writer, JsonSerializationContext ctx)
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
	}*/

	public class Sample : Object
	{
		public static void DoAction<T>(T obj)
		{
			Type t = typeof(T);
			stdout.printf("%s\n", t.name());
		}

		public static T ReturnType<T>(string val, int type)
		{
			if(type == 0)
			{
				return int.parse(val);
			}
			else
			{
				return (T)val;
			}
		}

		public static void main(string[] args)
		{
			//Type type = typeof(int[]);
			//TypeQuery q;
			//type.query(out q);
			//stdout.printf("%s\n", q.type_name);
			
			//string json = "{\"X\":-1,\"Y\":10.34,\"TBool\":true,\"TString\":\"SomeValue\",\"TBio\":{\"Name\":\"Taras\",\"LastName\":\"Shevchenko\"}}";
			File jsonFile = File.new_for_path("sample.json");
			FileInputStream fileStream = jsonFile.read();
			TestClass obj = JsonSerializer.DeserializeFromStream<TestClass>(fileStream);
			print("%d - %f - %s - %s - %s - %s\n", obj.X, obj.Y, obj.TBool.to_string(), obj.TString, obj.TBio.Name, obj.TBio.LastName);

	/*	Type type = typeof (Point);
	print ("%s\n", type.name ());
	print (" is-obj: %s\n", type.is_object ().to_string ());
	print (" is-abstr: %s\n", type.is_abstract ().to_string ());
	print (" is-classed: %s\n", type.is_classed ().to_string ());
	print (" is-derivable: %s\n", type.is_derivable ().to_string ());
	print (" is-derived: %s\n", type.is_derived ().to_string ());
	print (" is-fund: %s\n", type.is_fundamental ().to_string ());
	print (" is-inst: %s\n", type.is_instantiatable ().to_string ());
	print (" is-iface: %s\n", type.is_interface ().to_string ());
	print (" is-enum: %s\n", type.is_enum ().to_string ());
	print (" is-flags: %s\n", type.is_object ().to_string ());*/

			/*TestClass2 t2 = new TestClass2();
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
			stdout.printf("%s\n", json);*/
		}
	}
}
