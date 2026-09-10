import { connect, RetentionPolicy, DiscardPolicy } from "nats";

async function main() {
  const nc = await connect({ servers: "127.0.0.1:4448" });
  const jsm = await nc.jetstreamManager();

  const streams = [
    { name: "WHATSAPP_COMMANDS", subjects: ["WHATSAPP.commands", "WHATSAPP.commands.>"] },
    { name: "WHATSAPP_EVENTS", subjects: ["WHATSAPP.events", "WHATSAPP.events.>"], retention: RetentionPolicy.Interest, discard: DiscardPolicy.New },
    { name: "WHATSAPP_DOWNLOADS", subjects: ["WHATSAPP.download", "WHATSAPP.download.>"] },
    { name: "WHATSAPP_DEAD_LETTERS", subjects: ["WHATSAPP.dead_letter", "WHATSAPP.dead_letter.>"] }
  ];

  for (const s of streams) {
    try {
      await jsm.streams.add(s);
      console.log("Created stream", s.name);
    } catch (e: any) {
      console.log(s.name, e.message);
    }
  }

  await nc.close();
  process.exit(0);
}

main().catch(console.error);
