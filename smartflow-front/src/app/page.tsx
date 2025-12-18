import Header from "@/components/Header";
import PriceCard from "@/components/PriceCard";
import ClaimCard from "@/components/ClaimCard";
import MembershipCard from "@/components/MembershipCard";
import FooterCard from "@/components/FooterCard";

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col gap-3 p-6 max-w-[700px] mx-auto">
      <Header />
      <PriceCard />
      <ClaimCard />
      <MembershipCard />
      <FooterCard />
    </main>
  );
}
