import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function ClaimCard() {
  return (
    <Card className="p-6 space-y-4">
      <div className="flex justify-between">
        <div>
          <p className="text-xs text-muted-foreground">Last claim</p>
          <p>Jan 15, 2025 · 05:32</p>
        </div>

        <div>
          <p className="text-xs text-muted-foreground">Next claim</p>
          <p>14h 35m</p>
        </div>
      </div>

      <Button className="w-full">Claim your reward</Button>
    </Card>
  );
}
