import { Card } from "@/components/ui/card";

export default function FooterCard() {
  return (
    <Card className="p-6 text-sm space-y-2">
      <div>Contract: 0x1234...5678</div>
      <div>Network: Ethereum</div>
      <div>Your address: 0xabcd...ef12</div>
    </Card>
  );
}
