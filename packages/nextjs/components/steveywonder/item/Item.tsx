import { useEffect, useState } from "react";
import Image from "next/image";
import { Address } from "viem";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useCurrentAccessory } from "~~/hooks/steveywonder/useCurrentAccessory";
import { useSetAccessory } from "~~/hooks/steveywonder/useSetAccessory";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { Option } from "~~/types/steveywonder";

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
    <div className="flex flex-col gap-1 w-[12rem] rounded-t-lg bg-primary p-2">
      <div className="overflow-hidden rounded h-full w-full">
        {isLoading ? (
          <div className="bg-primary animate-pulse h-full w-full"></div>
        ) : (
          <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt={`${Number(tokenId)}`} width={420} height={420} />
        )}
      </div>
      {activeStatus === "loading" ? (
        <button
          className="flex justify-center items-center bg-secondary border border-gray-800 text-white p-2 rounded-lg cursor-not-allowed"
          disabled={activeStatus === "loading"}
        >
          <span className="loading loading-spinner"></span>
        </button>
      ) : activeTokenId === tokenId ? (
        <div className="text-center">Current</div>
      ) : (
        <button
          className="bg-secondary border border-gray-800 text-white p-2 rounded-lg"
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
