import { ItemContainer } from "~~/components/steveywonder";
import { ShowSteveyWonder } from "~~/components/steveywonder/main/ShowSteveyWonder";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";

const SteveyWonderId = () => {
  const { tokenURI } = useTokenURI({
    contractName: "SteveyWonder",
    tokenId: BigInt(1),
  });

  return (
    <section className="flex flex-1 justify-center items-center gap-12">
      <div className="flex gap-12">
        <ShowSteveyWonder data={tokenURI} width={518} height={607} />
        <div className={"bg-[#161728] w-[44rem] p-10 rounded-2xl shadow-md"}>
          <ItemContainer />
        </div>
      </div>
    </section>
  );
};

export default SteveyWonderId;
