import { useEffect, useState } from "react";
import { GetServerSidePropsContext, InferGetServerSidePropsType } from "next";
import { ItemContainer } from "~~/components/steveywonder";
import { ShowSteveyWonder } from "~~/components/steveywonder/main/ShowSteveyWonder";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useRenderTokenSVGWithoutBg } from "~~/hooks/steveywonder/useRenderTokenSVGWithoutBg";

const SteveyWonderId = ({ id }: InferGetServerSidePropsType<typeof getServerSideProps>) => {
  const [isloadingValid, setIsLoadingValid] = useState<boolean>(true);

  const { data: isValid } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "isTokenValid",
    args: [BigInt(id)],
  });

  useEffect(() => {
    if (isValid) {
      setIsLoadingValid(false);
    }
  }, [isValid]);

  const { base64Image } = useRenderTokenSVGWithoutBg(BigInt(id));

  return (
    <section className="flex flex-1 justify-center items-center gap-12">
      {isloadingValid ? (
        <div className="loading loading-spinner loading-lg"></div>
      ) : id < 1 || !isValid ? (
        <div className="flex justify-center items-center">
          <h1>Invalid Stevey Wonder</h1>
        </div>
      ) : (
        <div className="flex gap-12 h-[37.9375rem]">
          <ShowSteveyWonder data={base64Image} width={518} height={607} />
          <div className={"bg-[#161728] w-[50rem] p-10 rounded-2xl shadow-md"}>
            <ItemContainer tokenId={Number(id)} />
          </div>
        </div>
      )}
    </section>
  );
};

export const getServerSideProps = (context: GetServerSidePropsContext) => {
  const id = context.query.id;

  if (typeof id === "string") {
    return { props: { id: Number(id) } };
  }

  return { props: { id: -1 } };
};

export default SteveyWonderId;
