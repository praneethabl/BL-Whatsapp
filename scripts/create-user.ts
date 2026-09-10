import bcrypt from "bcrypt";
import { db } from "@blwhatsappcopy/database";
import { toDbDate } from "@blwhatsappcopy/shared";
import { createCompany } from "../apps/api/src/services/company/core.js";

async function main() {
  const email = "praneetha.businesslabs@gmail.com";
  const password = "Praneetha@BL2026";
  const hash = await bcrypt.hash(password, 12);
  const userId = crypto.randomUUID();

  await db
    .insertInto("users")
    .values({
      id: userId,
      email: email.toLowerCase(),
      password_hash: hash,
      name: "Praneetha",
      email_verified_at: toDbDate(),
      created_at: toDbDate(),
      updated_at: toDbDate(),
    })
    .execute();

  console.log("User created with ID:", userId);

  const company = await createCompany({ name: "Business Labs" }, userId);
  console.log("Company created successfully:", company.id, company.name);
  process.exit(0);
}

main().catch((err) => {
  console.error("Error creating user:", err);
  process.exit(1);
});
