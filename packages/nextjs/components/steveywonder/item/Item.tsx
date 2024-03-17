import { useEffect, useState } from "react";
import Image from "next/image";
import { Address } from "viem";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useCurrentAccessory } from "~~/hooks/steveywonder/useCurrentAccessory";
import { useSetAccessory } from "~~/hooks/steveywonder/useSetAccessory";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { Option } from "~~/types/steveywonder";
import { cn } from "~~/utils/cn";

type Props = {
  idx: bigint;
  option: Option;
  tba: Address | undefined;
  mainTokenId: number;
};

export const Item = ({ idx, option, tba, mainTokenId }: Props) => {
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const { data: tokenId } = useScaffoldContractRead({
    contractName: option,
    functionName: "tokenOfOwnerByIndex",
    args: [tba, idx],
  });

  const { tokenURI } = useTokenURI({
    contractName: option,
    tokenId,
  });

  const { tokenId: activeTokenId, status: activeStatus } = useCurrentAccessory({
    option,
    mainTokenId,
  });

  const { writeAsync, status } = useSetAccessory({
    option,
    tokenId: BigInt(mainTokenId),
    optionTokenId: tokenId,
  });

  useEffect(() => {
    console.log(status);
  }, [status]);

  useEffect(() => {
    if (!tokenURI) {
      setIsLoading(true);
      return;
    }

    setIsLoading(false);
  }, [tokenURI]);

  return (
    <div
      className={cn(
        "flex flex-col gap-1 w-[12rem] rounded-xl border border-gray-700 bg-[#1D1E35]",
        activeTokenId === tokenId && "border-[2px] border-white bg-[#242642]",
      )}
    >
      <div className="overflow-hidden rounded h-full w-full">
        {isLoading ? (
          <div className="bg-[#1D1E35] animate-pulse h-full w-full"></div>
        ) : (
          <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt={`${Number(tokenId)}`} width={420} height={420} />
        )}
      </div>
      {activeStatus === "loading" ? (
        <button
          className="flex justify-center items-center border border-gray-600 text-white rounded-xl p-2 cursor-not-allowed"
          disabled={activeStatus === "loading"}
        >
          <span className="loading loading-spinner"></span>
        </button>
      ) : activeTokenId === tokenId ? (
        <div className="flex justify-center items-center text-center font-medium p-2 m-1">Current</div>
      ) : (
        <button
          className="border border-gray-500 bg-white bg-opacity-5 p-2 m-1 rounded-xl"
          onClick={async () => {
            await writeAsync();
          }}
        >
          Set
        </button>
      )}
    </div>
  );
};
